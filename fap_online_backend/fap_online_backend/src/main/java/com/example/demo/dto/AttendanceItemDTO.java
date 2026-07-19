package com.example.demo.dto;

public class AttendanceItemDTO {

    private Integer studentId;

    private String status;

    private String note;

    public AttendanceItemDTO() {
    }

    public AttendanceItemDTO(Integer studentId,
                             String status,
                             String note) {

        this.studentId = studentId;
        this.status = status;
        this.note = note;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
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