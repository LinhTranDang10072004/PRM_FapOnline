package com.example.demo.dto;

public class AttendanceDto {
    private String subjectCode;
    private String subjectName;
    private Integer totalSlots;
    private Integer absentSlots;
    private Double absentPercent;

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
    public Integer getTotalSlots() { return totalSlots; }
    public void setTotalSlots(Integer totalSlots) { this.totalSlots = totalSlots; }
    public Integer getAbsentSlots() { return absentSlots; }
    public void setAbsentSlots(Integer absentSlots) { this.absentSlots = absentSlots; }
    public Double getAbsentPercent() { return absentPercent; }
    public void setAbsentPercent(Double absentPercent) { this.absentPercent = absentPercent; }
}
