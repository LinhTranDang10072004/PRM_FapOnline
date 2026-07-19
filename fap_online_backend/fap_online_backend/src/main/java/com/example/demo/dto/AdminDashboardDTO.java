package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

/**
 * UC: View Admin Dashboard
 * Tổng quan hệ thống: sinh viên, giáo viên, lớp, môn học.
 */
@Data
@Builder
public class AdminDashboardDTO {

    private long totalStudents;
    private long totalTeachers;
    private long totalClasses;
    private long totalSubjects;
}
