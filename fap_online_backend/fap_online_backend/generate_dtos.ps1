$dtoDir = "D:\VU-MOBILE-PROJECT\PRM_FapOnline\fap_online_backend\fap_online_backend\src\main\java\com\example\demo\dto"
$configDir = "D:\VU-MOBILE-PROJECT\PRM_FapOnline\fap_online_backend\fap_online_backend\src\main\java\com\example\demo\config"

if (!(Test-Path -Path $configDir)) {
    New-Item -ItemType Directory -Force -Path $configDir
}

$swaggerConfig = @"
package com.example.demo.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "bearerAuth";
        return new OpenAPI()
                .info(new Info().title("FapOnline API").version("v1").description("API documentation for Parent Role"))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components().addSecuritySchemes(securitySchemeName,
                        new SecurityScheme()
                                .name(securitySchemeName)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")));
    }
}
"@
Set-Content -Path "$configDir\SwaggerConfig.java" -Value $swaggerConfig -Encoding UTF8

$dtos = @{
    "WeeklyTimetableDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;
@Data @Builder public class WeeklyTimetableDTO {
    private LocalDate scheduleDate;
    private String subjectCode;
    private String roomName;
    private String timeSlot;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status;
}
"@;
    "AttendanceReportDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;
@Data @Builder public class AttendanceReportDTO {
    private String subjectCode;
    private LocalDate date;
    private String timeSlot;
    private String status;
}
"@;
    "GradeReportDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
@Data @Builder public class GradeReportDTO {
    private String subjectCode;
    private String gradeComponent;
    private BigDecimal score;
    private BigDecimal weight;
}
"@;
    "TranscriptDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
@Data @Builder public class TranscriptDTO {
    private String subjectCode;
    private String subjectName;
    private BigDecimal finalScore;
    private String status;
}
"@;
    "FeeDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
@Data @Builder public class FeeDTO {
    private Integer feeId;
    private String feeType;
    private BigDecimal amount;
    private BigDecimal paidAmount;
    private LocalDate dueDate;
    private String status;
}
"@;
    "NotificationDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
@Data @Builder public class NotificationDTO {
    private Integer notificationId;
    private String title;
    private String message;
    private LocalDateTime sentAt;
    private Boolean isRead;
}
"@;
    "ProfileDTO.java" = @"
package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;
@Data @Builder public class ProfileDTO {
    private String fullName;
    private String email;
    private String phone;
    private LocalDate dateOfBirth;
    private String gender;
    private String address;
    private String avatarUrl;
}
"@;
    "ChangePasswordRequest.java" = @"
package com.example.demo.dto;
import lombok.Data;
import jakarta.validation.constraints.NotBlank;
@Data public class ChangePasswordRequest {
    @NotBlank(message = "Old password is required")
    private String oldPassword;
    @NotBlank(message = "New password is required")
    private String newPassword;
}
"@;
}

foreach ($key in $dtos.Keys) {
    Set-Content -Path "$dtoDir\$key" -Value $dtos[$key] -Encoding UTF8
}
