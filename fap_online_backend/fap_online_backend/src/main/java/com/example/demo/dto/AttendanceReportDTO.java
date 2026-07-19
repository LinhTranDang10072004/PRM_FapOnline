package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;
@Data @Builder public class AttendanceReportDTO {
    private String subjectCode;
    private LocalDate date;
    private String timeSlot;
    private String status;
}
