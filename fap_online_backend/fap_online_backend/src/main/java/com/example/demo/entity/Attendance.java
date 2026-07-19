package com.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Attendances")
public class Attendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AttendanceId", nullable = false)
    private Integer attendanceId;

    @Column(name = "ScheduleId", nullable = false)
    private Integer scheduleId;

    @Column(name = "StudentId", nullable = false)
    private Integer studentId;

    @Column(name = "Status", nullable = false, length = 30)
    private String status;

    @Column(name = "Note", length = 500)
    private String note;

    @Column(name = "MarkedByTeacherId", nullable = false)
    private Integer markedByTeacherId;

    @Column(name = "MarkedAt", nullable = false)
    private LocalDateTime markedAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    public Integer getAttendanceId() {
        return attendanceId;
    }

    public void setAttendanceId(Integer attendanceId) {
        this.attendanceId = attendanceId;
    }

    public Integer getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(Integer scheduleId) {
        this.scheduleId = scheduleId;
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

    public Integer getMarkedByTeacherId() {
        return markedByTeacherId;
    }

    public void setMarkedByTeacherId(Integer markedByTeacherId) {
        this.markedByTeacherId = markedByTeacherId;
    }

    public LocalDateTime getMarkedAt() {
        return markedAt;
    }

    public void setMarkedAt(LocalDateTime markedAt) {
        this.markedAt = markedAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

}
