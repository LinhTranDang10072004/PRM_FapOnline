package com.example.demo.dto;

import java.math.BigDecimal;

public class CourseMarkSummaryDto {
    private Integer classId;
    private String classCode;
    private String subjectCode;
    private String subjectName;
    private BigDecimal average;
    private Double attendancePercent;
    private String result;

    public Integer getClassId() { return classId; }
    public void setClassId(Integer classId) { this.classId = classId; }
    public String getClassCode() { return classCode; }
    public void setClassCode(String classCode) { this.classCode = classCode; }
    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
    public BigDecimal getAverage() { return average; }
    public void setAverage(BigDecimal average) { this.average = average; }
    public Double getAttendancePercent() { return attendancePercent; }
    public void setAttendancePercent(Double attendancePercent) { this.attendancePercent = attendancePercent; }
    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }
}
