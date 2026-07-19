package com.example.demo.validation;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public class ApplicationSubmitRequest {
    @NotNull(message = "Loại đơn không được để trống")
    private Integer applicationTypeId;

    @NotBlank(message = "Tiêu đề không được để trống")
    private String title;

    @NotBlank(message = "Nội dung không được để trống")
    private String content;

    private Integer relatedScheduleId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String attachmentUrl;

    public Integer getApplicationTypeId() { return applicationTypeId; }
    public void setApplicationTypeId(Integer applicationTypeId) { this.applicationTypeId = applicationTypeId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Integer getRelatedScheduleId() { return relatedScheduleId; }
    public void setRelatedScheduleId(Integer relatedScheduleId) { this.relatedScheduleId = relatedScheduleId; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }
}
