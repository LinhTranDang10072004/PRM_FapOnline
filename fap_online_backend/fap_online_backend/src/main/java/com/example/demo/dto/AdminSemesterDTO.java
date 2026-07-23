package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

/**
 * Học kỳ dùng cho filter Admin Dashboard (năm + kỳ Fall/Spring/Summer).
 */
@Data
@Builder
public class AdminSemesterDTO {

    private Integer semesterId;
    private String semesterCode;
    private String semesterName;
    /** Kỳ học: Fall | Spring | Summer */
    private String term;
    private String academicYear;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
}
