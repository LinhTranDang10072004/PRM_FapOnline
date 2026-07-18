package com.example.demo.dto;

import java.math.BigDecimal;

public class GradeItemDTO {

    private Integer studentGradeId;

    private Integer studentId;

    private String studentName;

    private String studentCode;

    private Integer classGradeComponentId;

    private String componentName;

    private BigDecimal weight;

    private BigDecimal score;

    private String status;

    public GradeItemDTO(
            Integer studentGradeId,
            Integer studentId,
            String studentName,
            String studentCode,
            Integer classGradeComponentId,
            String componentName,
            BigDecimal weight,
            BigDecimal score,
            String status
    ) {
        this.studentGradeId = studentGradeId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.studentCode = studentCode;
        this.classGradeComponentId = classGradeComponentId;
        this.componentName = componentName;
        this.weight = weight;
        this.score = score;
        this.status = status;
    }
    public Integer getStudentGradeId() {
        return studentGradeId;
    }

    public void setStudentGradeId(Integer studentGradeId) {
        this.studentGradeId = studentGradeId;
    }


    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }


    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }


    public String getStudentCode() {
        return studentCode;
    }

    public void setStudentCode(String studentCode) {
        this.studentCode = studentCode;
    }


    public Integer getClassGradeComponentId() {
        return classGradeComponentId;
    }

    public void setClassGradeComponentId(Integer classGradeComponentId) {
        this.classGradeComponentId = classGradeComponentId;
    }


    public String getComponentName() {
        return componentName;
    }

    public void setComponentName(String componentName) {
        this.componentName = componentName;
    }


    public BigDecimal getWeight() {
        return weight;
    }

    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }


    public BigDecimal getScore() {
        return score;
    }

    public void setScore(BigDecimal score) {
        this.score = score;
    }


    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}