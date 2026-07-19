package com.example.demo.service;

import com.example.demo.dto.StaffDashboardDTO;

/**
 * UC-12: View Staff Dashboard
 * Tổng hợp dữ liệu học vụ cho Staff xem tổng quan.
 */
public interface StaffDashboardService {

    /**
     * Trả về toàn bộ số liệu tổng quan cho Staff Dashboard:
     * - Số lớp đang hoạt động
     * - Lịch học hôm nay
     * - Số đơn từ đang chờ xử lý
     * - Số giáo viên đã được phân công
     * - Tổng số sinh viên đang tham gia lớp
     */
    StaffDashboardDTO getDashboard();
}
