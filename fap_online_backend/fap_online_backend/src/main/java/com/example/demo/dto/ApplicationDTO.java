package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class ApplicationDTO {

    private Integer applicationId;

    // Thông tin sinh viên gửi đơn
    private Integer studentId;
    private String studentCode;
    private String studentName;

    // Loại đơn
    private Integer applicationTypeId;
    private String applicationTypeName;

    // Nội dung đơn
    private String title;
    private String content;

    // Thông tin thêm (cho đơn xin nghỉ)
    private Integer relatedScheduleId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String attachmentUrl;

    // Trạng thái đơn: Pending | Approved | Rejected | Cancelled
    private String status;

    // Thông tin xử lý (do Staff điền khi duyệt/từ chối)
    private Integer processedBy;
    private String processedByName;
    private LocalDateTime processedAt;
    private String processNote;

    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
