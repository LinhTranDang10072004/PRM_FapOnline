package com.example.demo.controller;

import com.example.demo.dto.ApplicationDTO;
import com.example.demo.dto.ProcessApplicationRequest;
import com.example.demo.service.ApplicationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UC-18: Process Application
 * Staff xem danh sách đơn từ của sinh viên, duyệt hoặc từ chối.
 *
 * Luồng chính:
 *  1. GET  /api/staff/applications?status=Pending   → xem danh sách đơn chờ
 *  2. GET  /api/staff/applications/{id}             → xem chi tiết đơn
 *  3+4+5. PUT /api/staff/applications/{id}/approve  → duyệt đơn
 *  3+4+5. PUT /api/staff/applications/{id}/reject   → từ chối đơn (bắt buộc processNote)
 */
@RestController
@RequestMapping("/api/staff/applications")
@RequiredArgsConstructor
@Tag(name = "Staff - Applications", description = "UC-18: Xem và xử lý đơn từ của sinh viên")
@PreAuthorize("hasRole('STAFF')")
public class ApplicationController {

    private final ApplicationService applicationService;

    /**
     * Bước 1 (luồng chính): Staff xem danh sách đơn.
     * Query param ?status=Pending  → chỉ lấy đơn đang chờ xử lý.
     * Không truyền status          → lấy toàn bộ đơn.
     */
    @GetMapping
    @Operation(
            summary = "Danh sách đơn từ",
            description = "Lọc theo trạng thái (status). Ví dụ: ?status=Pending để xem đơn chờ xử lý. " +
                          "Bỏ trống để xem tất cả. Trạng thái hợp lệ: Pending, Approved, Rejected, Cancelled."
    )
    public ResponseEntity<List<ApplicationDTO>> getApplications(
            @Parameter(description = "Lọc theo trạng thái: Pending | Approved | Rejected | Cancelled")
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(applicationService.getApplications(status));
    }

    /**
     * Bước 2 (luồng chính): Staff xem chi tiết một đơn.
     * Hiển thị: loại đơn, nội dung, file đính kèm, thông tin sinh viên.
     */
    @GetMapping("/{applicationId}")
    @Operation(
            summary = "Chi tiết đơn từ",
            description = "Xem loại đơn, nội dung, file đính kèm và thông tin sinh viên gửi đơn."
    )
    public ResponseEntity<ApplicationDTO> getApplicationById(@PathVariable Integer applicationId) {
        return ResponseEntity.ok(applicationService.getApplicationById(applicationId));
    }

    /**
     * Bước 3–5 (luồng chính): Staff duyệt đơn.
     * BR-A: Chỉ đơn Pending mới được xử lý.
     * BR-D: Mỗi đơn chỉ xử lý một lần.
     * BR-E: Hệ thống tự lưu processedBy (từ JWT) + processedAt (thời gian hiện tại).
     * processNote là tùy chọn khi approve.
     */
    @PutMapping("/{applicationId}/approve")
    @Operation(
            summary = "Duyệt đơn (Approve)",
            description = "Chỉ được duyệt đơn có trạng thái Pending. " +
                          "Hệ thống tự ghi nhận người duyệt và thời gian. " +
                          "Ghi chú (processNote) là tùy chọn khi duyệt."
    )
    public ResponseEntity<ApplicationDTO> approveApplication(
            @PathVariable Integer applicationId,
            @Valid @RequestBody ProcessApplicationRequest request) {
        return ResponseEntity.ok(applicationService.approveApplication(applicationId, request));
    }

    /**
     * Bước 3–5 (luồng chính): Staff từ chối đơn.
     * BR-A: Chỉ đơn Pending mới được xử lý.
     * BR-B: Bắt buộc phải có lý do (processNote không được trống).
     * BR-D: Mỗi đơn chỉ xử lý một lần.
     * BR-E: Hệ thống tự lưu processedBy (từ JWT) + processedAt.
     */
    @PutMapping("/{applicationId}/reject")
    @Operation(
            summary = "Từ chối đơn (Reject)",
            description = "Chỉ được từ chối đơn có trạng thái Pending. " +
                          "BẮT BUỘC phải điền lý do từ chối trong trường processNote. " +
                          "Hệ thống tự ghi nhận người từ chối và thời gian."
    )
    public ResponseEntity<ApplicationDTO> rejectApplication(
            @PathVariable Integer applicationId,
            @Valid @RequestBody ProcessApplicationRequest request) {
        return ResponseEntity.ok(applicationService.rejectApplication(applicationId, request));
    }
}
