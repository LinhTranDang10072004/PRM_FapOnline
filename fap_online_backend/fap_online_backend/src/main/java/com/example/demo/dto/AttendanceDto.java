package com.example.demo.dto;

public class AttendanceDto {
    private String subjectCode;
    private String subjectName;
    /** Tổng buổi chuẩn của kỳ (mặc định 20). */
    private Integer totalSlots;
    private Integer absentSlots;
    private Integer presentSlots;
    /** % vắng = absent / 20 */
    private Double absentPercent;
    /** % tham gia = (20 - absent) / 20 */
    private Double presentPercent;
    private Integer semesterId;
    private String semesterCode;
    private String semesterName;

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
    public Integer getTotalSlots() { return totalSlots; }
    public void setTotalSlots(Integer totalSlots) { this.totalSlots = totalSlots; }
    public Integer getAbsentSlots() { return absentSlots; }
    public void setAbsentSlots(Integer absentSlots) { this.absentSlots = absentSlots; }
    public Integer getPresentSlots() { return presentSlots; }
    public void setPresentSlots(Integer presentSlots) { this.presentSlots = presentSlots; }
    public Double getAbsentPercent() { return absentPercent; }
    public void setAbsentPercent(Double absentPercent) { this.absentPercent = absentPercent; }
    public Double getPresentPercent() { return presentPercent; }
    public void setPresentPercent(Double presentPercent) { this.presentPercent = presentPercent; }
    public Integer getSemesterId() { return semesterId; }
    public void setSemesterId(Integer semesterId) { this.semesterId = semesterId; }
    public String getSemesterCode() { return semesterCode; }
    public void setSemesterCode(String semesterCode) { this.semesterCode = semesterCode; }
    public String getSemesterName() { return semesterName; }
    public void setSemesterName(String semesterName) { this.semesterName = semesterName; }
}
