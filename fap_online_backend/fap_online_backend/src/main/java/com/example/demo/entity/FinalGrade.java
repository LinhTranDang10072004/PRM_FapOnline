package com.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "FinalGrades")
public class FinalGrade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "FinalGradeId", nullable = false)
    private Integer finalGradeId;

    @Column(name = "ClassId", nullable = false)
    private Integer classId;

    @Column(name = "StudentId", nullable = false)
    private Integer studentId;

    @Column(name = "FinalScore")
    private BigDecimal finalScore;

    @Column(name = "LetterGrade", length = 5)
    private String letterGrade;

    @Column(name = "Result", length = 20)
    private String result;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    @Column(name = "PublishedAt")
    private LocalDateTime publishedAt;

    @Column(name = "PublishedBy")
    private Integer publishedBy;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    public Integer getFinalGradeId() {
        return finalGradeId;
    }

    public void setFinalGradeId(Integer finalGradeId) {
        this.finalGradeId = finalGradeId;
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

    public BigDecimal getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(BigDecimal finalScore) {
        this.finalScore = finalScore;
    }

    public String getLetterGrade() {
        return letterGrade;
    }

    public void setLetterGrade(String letterGrade) {
        this.letterGrade = letterGrade;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }

    public void setPublishedAt(LocalDateTime publishedAt) {
        this.publishedAt = publishedAt;
    }

    public Integer getPublishedBy() {
        return publishedBy;
    }

    public void setPublishedBy(Integer publishedBy) {
        this.publishedBy = publishedBy;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

}
