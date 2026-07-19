package com.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ClassStudents")
@IdClass(ClassStudentId.class)
public class ClassStudent {

    @Id
    @Column(name = "ClassId", nullable = false)
    private Integer classId;

    @Id
    @Column(name = "StudentId", nullable = false)
    private Integer studentId;

    @Column(name = "EnrolledAt", nullable = false)
    private LocalDateTime enrolledAt;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    public Integer getClassId() {
        return classId;
    }

    public void setClassId(Integer classId) {
        this.classId = classId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public LocalDateTime getEnrolledAt() {
        return enrolledAt;
    }

    public void setEnrolledAt(LocalDateTime enrolledAt) {
        this.enrolledAt = enrolledAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

}
