package com.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ParentStudents")
@IdClass(ParentStudentId.class)
public class ParentStudent {

    @Id
    @Column(name = "ParentId", nullable = false)
    private Integer parentId;

    @Id
    @Column(name = "StudentId", nullable = false)
    private Integer studentId;

    @Column(name = "Relationship", nullable = false, length = 50)
    private String relationship;

    @Column(name = "IsPrimaryContact", nullable = false)
    private Boolean isPrimaryContact;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public String getRelationship() {
        return relationship;
    }

    public void setRelationship(String relationship) {
        this.relationship = relationship;
    }

    public Boolean getIsPrimaryContact() {
        return isPrimaryContact;
    }

    public void setIsPrimaryContact(Boolean isPrimaryContact) {
        this.isPrimaryContact = isPrimaryContact;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
