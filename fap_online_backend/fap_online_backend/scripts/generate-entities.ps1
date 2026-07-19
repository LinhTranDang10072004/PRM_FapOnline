param(
    [string]$Server = "LAPTOP-715LSPJN",
    [string]$Database = "PRM_EducationManagement",
    [string]$User = "sa",
    [string]$Password = "123",
    [string]$BasePackage = "com.example.demo.entity"
)

$ErrorActionPreference = "Stop"

function To-PascalCase([string]$name) {
    ($name -split '[_\s]+' | Where-Object { $_ -ne "" } | ForEach-Object {
        if ($_.Length -eq 1) { $_.ToUpper() } else { $_.Substring(0,1).ToUpper() + $_.Substring(1) }
    }) -join ""
}

function To-CamelCase([string]$name) {
    $p = To-PascalCase $name
    if ([string]::IsNullOrWhiteSpace($p)) { return $name }
    return $p.Substring(0,1).ToLower() + $p.Substring(1)
}

function SqlToJavaType([string]$sqlType) {
    switch ($sqlType.ToLower()) {
        "int" { "Integer" }
        "bigint" { "Long" }
        "smallint" { "Short" }
        "tinyint" { "Short" }
        "bit" { "Boolean" }
        "decimal" { "BigDecimal" }
        "numeric" { "BigDecimal" }
        "float" { "Double" }
        "real" { "Float" }
        "date" { "LocalDate" }
        "datetime" { "LocalDateTime" }
        "datetime2" { "LocalDateTime" }
        "smalldatetime" { "LocalDateTime" }
        "time" { "LocalTime" }
        "char" { "String" }
        "nchar" { "String" }
        "varchar" { "String" }
        "nvarchar" { "String" }
        "text" { "String" }
        "ntext" { "String" }
        "uniqueidentifier" { "UUID" }
        default { "String" }
    }
}

function Build-Field([hashtable]$c, [bool]$forEmbeddable) {
    $ann = @()
    if (-not $forEmbeddable -and $c.IsPk -eq "YES") {
        $ann += "    @Id"
        if ($c.IsIdentity -eq "1") {
            $ann += "    @GeneratedValue(strategy = GenerationType.IDENTITY)"
        }
    }

    $attrs = @("name = `"$($c.ColumnName)`"")
    if ($c.Nullable -eq "NO") { $attrs += "nullable = false" }
    if ($c.MaxLen -and $c.MaxLen -ne "NULL" -and $c.MaxLen -ne "-1" -and $c.JavaType -eq "String") {
        $attrs += "length = $($c.MaxLen)"
    }
    if ($c.IsIdentity -eq "1" -and $forEmbeddable) {
        # no-op for key classes
    }
    $ann += "    @Column($($attrs -join ", "))"
    $annText = $ann -join "`n"
    $field = "    private $($c.JavaType) $($c.FieldName);"
    return @($annText, $field) -join "`n"
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$srcRoot = Join-Path $projectRoot "src\main\java"
$packagePath = Join-Path $srcRoot ($BasePackage -replace "\.", "\")

if (Test-Path $packagePath) {
    Remove-Item -Recurse -Force "$packagePath\*.java" -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $packagePath -Force | Out-Null
}

$columnsSql = @"
SELECT t.TABLE_NAME, c.ORDINAL_POSITION, c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH,
       c.IS_NULLABLE,
       CASE WHEN pk.COLUMN_NAME IS NULL THEN 'NO' ELSE 'YES' END AS IS_PK,
       COLUMNPROPERTY(OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.TABLES t
JOIN INFORMATION_SCHEMA.COLUMNS c
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
LEFT JOIN (
    SELECT ku.TABLE_SCHEMA, ku.TABLE_NAME, ku.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
      ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
    WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
) pk
  ON pk.TABLE_SCHEMA = c.TABLE_SCHEMA AND pk.TABLE_NAME = c.TABLE_NAME AND pk.COLUMN_NAME = c.COLUMN_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION
"@

$raw = sqlcmd -S $Server -U $User -P $Password -d $Database -Q $columnsSql -s "|" -W -h-1
$rows = @()
foreach ($line in $raw) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split "\|"
    if ($parts.Length -lt 8) { continue }
    $rows += [pscustomobject]@{
        TableName = $parts[0].Trim()
        Ordinal = [int]$parts[1].Trim()
        ColumnName = $parts[2].Trim()
        DataType = $parts[3].Trim()
        MaxLen = $parts[4].Trim()
        Nullable = $parts[5].Trim()
        IsPk = $parts[6].Trim()
        IsIdentity = $parts[7].Trim()
    }
}

$grouped = $rows | Group-Object TableName | Sort-Object Name

foreach ($g in $grouped) {
    $table = $g.Name
    $entityName = if ($table.EndsWith("ies")) { $table.Substring(0, $table.Length - 3) + "y" } elseif ($table.EndsWith("s")) { $table.Substring(0, $table.Length - 1) } else { $table }
    $entityName = To-PascalCase $entityName
    if ($entityName -eq "Class" -or $entityName -eq "Classe") { $entityName = "SchoolClass" }
    $pkCols = $g.Group | Where-Object { $_.IsPk -eq "YES" }
    $isCompositePk = ($pkCols.Count -gt 1)

    $imports = [System.Collections.Generic.HashSet[string]]::new()
    $imports.Add("jakarta.persistence.*") | Out-Null

    $cols = @()
    foreach ($c in ($g.Group | Sort-Object Ordinal)) {
        $javaType = SqlToJavaType $c.DataType
        if ($javaType -eq "LocalDate") { $imports.Add("java.time.LocalDate") | Out-Null }
        if ($javaType -eq "LocalDateTime") { $imports.Add("java.time.LocalDateTime") | Out-Null }
        if ($javaType -eq "LocalTime") { $imports.Add("java.time.LocalTime") | Out-Null }
        if ($javaType -eq "BigDecimal") { $imports.Add("java.math.BigDecimal") | Out-Null }
        if ($javaType -eq "UUID") { $imports.Add("java.util.UUID") | Out-Null }
        $cols += @{
            ColumnName = $c.ColumnName
            FieldName = To-CamelCase $c.ColumnName
            JavaType = $javaType
            MaxLen = $c.MaxLen
            Nullable = $c.Nullable
            IsPk = $c.IsPk
            IsIdentity = $c.IsIdentity
        }
    }

    $classBody = New-Object System.Text.StringBuilder
    [void]$classBody.AppendLine("package $BasePackage;")
    [void]$classBody.AppendLine("")
    foreach ($i in ($imports | Sort-Object)) { [void]$classBody.AppendLine("import $i;") }
    [void]$classBody.AppendLine("")
    [void]$classBody.AppendLine("@Entity")
    [void]$classBody.AppendLine("@Table(name = `"$table`")")
    if ($isCompositePk) {
        $imports.Add("java.io.Serializable") | Out-Null
        [void]$classBody.AppendLine("@IdClass($entityName" + "Id.class)")
    }
    [void]$classBody.AppendLine("public class $entityName {")
    [void]$classBody.AppendLine("")

    foreach ($c in $cols) {
        [void]$classBody.AppendLine((Build-Field $c $false))
        [void]$classBody.AppendLine("")
    }

    foreach ($c in $cols) {
        $method = $c.FieldName.Substring(0,1).ToUpper() + $c.FieldName.Substring(1)
        [void]$classBody.AppendLine("    public $($c.JavaType) get$method() {")
        [void]$classBody.AppendLine("        return $($c.FieldName);")
        [void]$classBody.AppendLine("    }")
        [void]$classBody.AppendLine("")
        [void]$classBody.AppendLine("    public void set$method($($c.JavaType) $($c.FieldName)) {")
        [void]$classBody.AppendLine("        this.$($c.FieldName) = $($c.FieldName);")
        [void]$classBody.AppendLine("    }")
        [void]$classBody.AppendLine("")
    }

    [void]$classBody.AppendLine("}")
    $entityFile = Join-Path $packagePath "$entityName.java"
    [System.IO.File]::WriteAllText($entityFile, $classBody.ToString(), [System.Text.UTF8Encoding]::new($false))

    if ($isCompositePk) {
        $idImports = @(
            "import java.io.Serializable;",
            "import java.util.Objects;"
        )
        $needLocalDate = $false
        $needLocalDateTime = $false
        $needLocalTime = $false
        $needBigDecimal = $false
        $needUUID = $false

        foreach ($c in $cols | Where-Object { $_.IsPk -eq "YES" }) {
            switch ($c.JavaType) {
                "LocalDate" { $needLocalDate = $true }
                "LocalDateTime" { $needLocalDateTime = $true }
                "LocalTime" { $needLocalTime = $true }
                "BigDecimal" { $needBigDecimal = $true }
                "UUID" { $needUUID = $true }
            }
        }
        if ($needLocalDate) { $idImports += "import java.time.LocalDate;" }
        if ($needLocalDateTime) { $idImports += "import java.time.LocalDateTime;" }
        if ($needLocalTime) { $idImports += "import java.time.LocalTime;" }
        if ($needBigDecimal) { $idImports += "import java.math.BigDecimal;" }
        if ($needUUID) { $idImports += "import java.util.UUID;" }

        $idClass = New-Object System.Text.StringBuilder
        [void]$idClass.AppendLine("package $BasePackage;")
        [void]$idClass.AppendLine("")
        foreach ($i in $idImports) { [void]$idClass.AppendLine($i) }
        [void]$idClass.AppendLine("")
        [void]$idClass.AppendLine("public class $entityName" + "Id implements Serializable {")
        [void]$idClass.AppendLine("")
        foreach ($c in $cols | Where-Object { $_.IsPk -eq "YES" }) {
            [void]$idClass.AppendLine("    private $($c.JavaType) $($c.FieldName);")
        }
        [void]$idClass.AppendLine("")
        [void]$idClass.AppendLine("    public $entityName" + "Id() {")
        [void]$idClass.AppendLine("    }")
        [void]$idClass.AppendLine("")
        foreach ($c in $cols | Where-Object { $_.IsPk -eq "YES" }) {
            $method = $c.FieldName.Substring(0,1).ToUpper() + $c.FieldName.Substring(1)
            [void]$idClass.AppendLine("    public $($c.JavaType) get$method() {")
            [void]$idClass.AppendLine("        return $($c.FieldName);")
            [void]$idClass.AppendLine("    }")
            [void]$idClass.AppendLine("")
            [void]$idClass.AppendLine("    public void set$method($($c.JavaType) $($c.FieldName)) {")
            [void]$idClass.AppendLine("        this.$($c.FieldName) = $($c.FieldName);")
            [void]$idClass.AppendLine("    }")
            [void]$idClass.AppendLine("")
        }

        $pkFields = @($cols | Where-Object { $_.IsPk -eq "YES" })
        $eqExpr = ($pkFields | ForEach-Object { "Objects.equals($($_.FieldName), that.$($_.FieldName))" }) -join " && "
        $hashArgs = ($pkFields | ForEach-Object { $_.FieldName }) -join ", "
        [void]$idClass.AppendLine("    @Override")
        [void]$idClass.AppendLine("    public boolean equals(Object o) {")
        [void]$idClass.AppendLine("        if (this == o) return true;")
        [void]$idClass.AppendLine("        if (o == null || getClass() != o.getClass()) return false;")
        [void]$idClass.AppendLine("        $entityName" + "Id that = ($entityName" + "Id) o;")
        [void]$idClass.AppendLine("        return $eqExpr;")
        [void]$idClass.AppendLine("    }")
        [void]$idClass.AppendLine("")
        [void]$idClass.AppendLine("    @Override")
        [void]$idClass.AppendLine("    public int hashCode() {")
        [void]$idClass.AppendLine("        return Objects.hash($hashArgs);")
        [void]$idClass.AppendLine("    }")
        [void]$idClass.AppendLine("}")
        $idFile = Join-Path $packagePath ($entityName + "Id.java")
        [System.IO.File]::WriteAllText($idFile, $idClass.ToString(), [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "Generated entities to $packagePath"
