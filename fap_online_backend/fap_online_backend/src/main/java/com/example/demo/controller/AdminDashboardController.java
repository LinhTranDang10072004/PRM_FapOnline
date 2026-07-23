package com.example.demo.controller;

import com.example.demo.dto.AdminDashboardDTO;
import com.example.demo.dto.AdminSemesterDTO;
import com.example.demo.service.AdminDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * UC: View Admin Dashboard
 * Tổng quan số sinh viên, giáo viên, lớp, môn học — có filter theo năm / kỳ.
 */
@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
@Tag(name = "Admin - Dashboard")
@PreAuthorize("hasRole('ADMIN')")
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    @GetMapping
    @Operation(summary = "Lấy tổng quan Admin Dashboard (filter theo năm học / kỳ Fall-Spring-Summer)")
    public ResponseEntity<AdminDashboardDTO> getDashboard(
            @Parameter(description = "Năm học, ví dụ 2025-2026") @RequestParam(required = false) String academicYear,
            @Parameter(description = "Kỳ học: Fall | Spring | Summer") @RequestParam(required = false) String term) {
        return ResponseEntity.ok(adminDashboardService.getDashboard(academicYear, term));
    }

    @GetMapping("/semesters")
    @Operation(summary = "Danh sách học kỳ dùng cho filter")
    public ResponseEntity<List<AdminSemesterDTO>> getSemesters() {
        return ResponseEntity.ok(adminDashboardService.getSemesters());
    }

    @GetMapping("/academic-years")
    @Operation(summary = "Danh sách năm học dùng cho filter")
    public ResponseEntity<List<String>> getAcademicYears() {
        return ResponseEntity.ok(adminDashboardService.getAcademicYears());
    }
}
