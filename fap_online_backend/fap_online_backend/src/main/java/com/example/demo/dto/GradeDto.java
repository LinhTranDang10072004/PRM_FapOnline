package com.example.demo.dto;
import java.math.BigDecimal;
import java.util.List;
public class GradeDto {
    private Integer classId;
    private String classCode;
    private String subjectCode;
    private String subjectName;
    private BigDecimal finalScore;
    private Double attendancePercent;
    private String result;
    private Integer semesterId;
    private String semesterCode;
    private String semesterName;
    private List<ComponentGrade> components;

    public Integer getClassId() { return classId; }
    public void setClassId(Integer classId) { this.classId = classId; }
    public String getClassCode() { return classCode; }
    public void setClassCode(String classCode) { this.classCode = classCode; }
    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
    public BigDecimal getFinalScore() { return finalScore; }
    public void setFinalScore(BigDecimal finalScore) { this.finalScore = finalScore; }
    public Double getAttendancePercent() { return attendancePercent; }
    public void setAttendancePercent(Double attendancePercent) { this.attendancePercent = attendancePercent; }
    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }
    public Integer getSemesterId() { return semesterId; }
    public void setSemesterId(Integer semesterId) { this.semesterId = semesterId; }
    public String getSemesterCode() { return semesterCode; }
    public void setSemesterCode(String semesterCode) { this.semesterCode = semesterCode; }
    public String getSemesterName() { return semesterName; }
    public void setSemesterName(String semesterName) { this.semesterName = semesterName; }
    public List<ComponentGrade> getComponents() { return components; }
    public void setComponents(List<ComponentGrade> components) { this.components = components; }

    public static class ComponentGrade {
        private String componentName;
        private BigDecimal weight;
        private BigDecimal score;

        public String getComponentName() { return componentName; }
        public void setComponentName(String componentName) { this.componentName = componentName; }
        public BigDecimal getWeight() { return weight; }
        public void setWeight(BigDecimal weight) { this.weight = weight; }
        public BigDecimal getScore() { return score; }
        public void setScore(BigDecimal score) { this.score = score; }
    }
}
