package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * UC-12: View Staff Dashboard
 * Response DTO trả về tổng quan học vụ cho Staff.
 */
@Data
@Builder
public class StaffDashboardDTO {

    /** Số lớp đang hoạt động (status ≠ Cancelled, Completed) */
    private long totalActiveClasses;

    /** Số đơn từ đang chờ xử lý (status = Pending) */
    private long totalPendingApplications;

    /** Số lớp có giáo viên được phân công (mainTeacherId IS NOT NULL) */
    private long totalAssignedTeachers;

    /** Tổng số sinh viên (distinct) đang tham gia ít nhất một lớp */
    private long totalEnrolledStudents;

    /** Danh sách lịch học hôm nay (scheduleDate = TODAY) */
    private List<ScheduleDTO> todaySchedules;
}
