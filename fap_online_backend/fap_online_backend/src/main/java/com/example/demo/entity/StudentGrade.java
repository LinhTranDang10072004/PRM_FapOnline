package com.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "StudentGrades")
public class StudentGrade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "StudentGradeId", nullable = false)
    private Integer studentGradeId;

    @Column(name = "ClassId", nullable = false)
    private Integer classId;

    @Column(name = "StudentId", nullable = false)
    private Integer studentId;

    @Column(name = "ClassGradeComponentId", nullable = false)
    private Integer classGradeComponentId;

    @Column(name = "Score")
    private BigDecimal score;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    @Column(name = "EnteredByTeacherId", nullable = false)
    private Integer enteredByTeacherId;

    @Column(name = "EnteredAt", nullable = false)
    private LocalDateTime enteredAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @Column(name = "SemesterId")
    private Integer semesterId;

    public Integer getStudentGradeId() {
        return studentGradeId;
    }

    public void setStudentGradeId(Integer studentGradeId) {
        this.studentGradeId = studentGradeId;
    }

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

    public Integer getClassGradeComponentId() {
        return classGradeComponentId;
    }

    public void setClassGradeComponentId(Integer classGradeComponentId) {
        this.classGradeComponentId = classGradeComponentId;
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

    public Integer getEnteredByTeacherId() {
        return enteredByTeacherId;
    }

    public void setEnteredByTeacherId(Integer enteredByTeacherId) {
        this.enteredByTeacherId = enteredByTeacherId;
    }

    public LocalDateTime getEnteredAt() {
        return enteredAt;
    }

    public void setEnteredAt(LocalDateTime enteredAt) {
        this.enteredAt = enteredAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getSemesterId() {
        return semesterId;
    }

    public void setSemesterId(Integer semesterId) {
        this.semesterId = semesterId;
    }

}
