package com.example.demo.dto;

public class GradeStudentDTO {

    private Integer studentId;

    private String studentCode;

    private String fullName;

    private Double grade;

    public GradeStudentDTO() {
    }

    public GradeStudentDTO(
            Integer studentId,
            String studentCode,
            String fullName,
            Double grade
    ) {
        this.studentId = studentId;
        this.studentCode = studentCode;
        this.fullName = fullName;
        this.grade = grade;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public String getStudentCode() {
        return studentCode;
    }

    public void setStudentCode(String studentCode) {
        this.studentCode = studentCode;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public Double getGrade() {
        return grade;
    }

    public void setGrade(Double grade) {
        this.grade = grade;
    }
}