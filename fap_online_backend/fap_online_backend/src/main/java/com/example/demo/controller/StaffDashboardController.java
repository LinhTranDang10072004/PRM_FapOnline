package com.example.demo.controller;

import com.example.demo.dto.StaffDashboardDTO;
import com.example.demo.service.StaffDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * UC-12: View Staff Dashboard
 *
 * Trả về tổng quan học vụ cho Staff:
 *  - Số lớp đang hoạt động
 *  - Số đơn từ đang chờ xử lý
 *  - Số lớp có giáo viên được phân công
 *  - Tổng số sinh viên đang tham gia lớp
 *  - Danh sách lịch học hôm nay
 *
 * Business Rule BR-10: Chỉ Staff đã đăng nhập mới truy cập được.
 */
@RestController
@RequestMapping("/api/staff/dashboard")
@RequiredArgsConstructor
@Tag(name = "Staff - Dashboard")
@PreAuthorize("hasRole('STAFF')")
public class StaffDashboardController {

    private final StaffDashboardService staffDashboardService;

    @GetMapping
    @Operation(summary = "Lấy tổng quan Staff Dashboard")
    public ResponseEntity<?> getDashboard() {
        try {
            return ResponseEntity.ok(staffDashboardService.getDashboard());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(java.util.Map.of("message", e.getMessage() != null ? e.getMessage() : e.toString(), "trace", e.getStackTrace()[0].toString()));
        }
    }
}
