package com.example.demo.dto;

public class AttendanceStudentDTO {

    private Integer studentId;

    private String studentCode;

    private String fullName;

    private String status;

    private String note;

    public AttendanceStudentDTO() {
    }

    public AttendanceStudentDTO(Integer studentId,
                                String studentCode,
                                String fullName,
                                String status,
                                String note) {

        this.studentId = studentId;
        this.studentCode = studentCode;
        this.fullName = fullName;
        this.status = status;
        this.note = note;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

}