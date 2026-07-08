package com.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "Applications")
public class Application {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ApplicationId", nullable = false)
    private Integer applicationId;

    @Column(name = "StudentId", nullable = false)
    private Integer studentId;

    @Column(name = "ApplicationTypeId", nullable = false)
    private Integer applicationTypeId;

    @Column(name = "Title", nullable = false, length = 200)
    private String title;

    @Column(name = "Content", nullable = false)
    private String content;

    @Column(name = "RelatedScheduleId")
    private Integer relatedScheduleId;

    @Column(name = "StartDate")
    private LocalDate startDate;

    @Column(name = "EndDate")
    private LocalDate endDate;

    @Column(name = "AttachmentUrl", length = 500)
    private String attachmentUrl;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    @Column(name = "ProcessedBy")
    private Integer processedBy;

    @Column(name = "ProcessedAt")
    private LocalDateTime processedAt;

    @Column(name = "ProcessNote", length = 1000)
    private String processNote;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    public Integer getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(Integer applicationId) {
        this.applicationId = applicationId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public Integer getApplicationTypeId() {
        return applicationTypeId;
    }

    public void setApplicationTypeId(Integer applicationTypeId) {
        this.applicationTypeId = applicationTypeId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getRelatedScheduleId() {
        return relatedScheduleId;
    }

    public void setRelatedScheduleId(Integer relatedScheduleId) {
        this.relatedScheduleId = relatedScheduleId;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getAttachmentUrl() {
        return attachmentUrl;
    }

    public void setAttachmentUrl(String attachmentUrl) {
        this.attachmentUrl = attachmentUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getProcessedBy() {
        return processedBy;
    }

    public void setProcessedBy(Integer processedBy) {
        this.processedBy = processedBy;
    }

    public LocalDateTime getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(LocalDateTime processedAt) {
        this.processedAt = processedAt;
    }

    public String getProcessNote() {
        return processNote;
    }

    public void setProcessNote(String processNote) {
        this.processNote = processNote;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

}
