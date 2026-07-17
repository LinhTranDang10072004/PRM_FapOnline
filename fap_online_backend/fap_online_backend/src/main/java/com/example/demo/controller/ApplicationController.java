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


@RestController
@RequestMapping("/api/staff/applications")
@RequiredArgsConstructor
@Tag(name = "Staff - Applications", description = "UC-18: Xem và xử lý đơn từ của sinh viên")
@PreAuthorize("hasRole('STAFF')")
public class ApplicationController {

    private final ApplicationService applicationService;


    @GetMapping
    @Operation(
            summary = "Danh sách đơn từ")
    public ResponseEntity<List<ApplicationDTO>> getApplications(
            @Parameter(description = "Lọc theo trạng thái: Pending | Approved | Rejected | Cancelled")
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(applicationService.getApplications(status));
    }

    @GetMapping("/{applicationId}")
    @Operation(
            summary = "Chi tiết đơn từ",
            description = "Xem loại đơn, nội dung, file đính kèm và thông tin sinh viên gửi đơn."
    )
    public ResponseEntity<ApplicationDTO> getApplicationById(@PathVariable Integer applicationId) {
        return ResponseEntity.ok(applicationService.getApplicationById(applicationId));
    }

  
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
