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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/staff/applications")
@RequiredArgsConstructor
@Tag(name = "Staff - Applications", description = "UC-18: Xem và xử lý đơn từ của sinh viên")
@PreAuthorize("hasAnyRole('STAFF','ADMIN')")
public class StaffApplicationController {

	private final ApplicationService applicationService;

	@GetMapping
	@Operation(summary = "Danh sách đơn từ")
	public ResponseEntity<List<ApplicationDTO>> getApplications(
			@Parameter(description = "Lọc theo trạng thái: Pending | Approved | Rejected | Cancelled")
			@RequestParam(required = false) String status) {
		return ResponseEntity.ok(applicationService.getApplications(status));
	}

	@GetMapping("/{applicationId}")
	@Operation(summary = "Chi tiết đơn từ")
	public ResponseEntity<ApplicationDTO> getApplicationById(@PathVariable Integer applicationId) {
		return ResponseEntity.ok(applicationService.getApplicationById(applicationId));
	}

	@PutMapping("/{applicationId}/approve")
	@Operation(summary = "Duyệt đơn (Approve)")
	public ResponseEntity<ApplicationDTO> approveApplication(
			@PathVariable Integer applicationId,
			@Valid @RequestBody ProcessApplicationRequest request) {
		return ResponseEntity.ok(applicationService.approveApplication(applicationId, request));
	}

	@PutMapping("/{applicationId}/reject")
	@Operation(summary = "Từ chối đơn (Reject)")
	public ResponseEntity<ApplicationDTO> rejectApplication(
			@PathVariable Integer applicationId,
			@Valid @RequestBody ProcessApplicationRequest request) {
		return ResponseEntity.ok(applicationService.rejectApplication(applicationId, request));
	}
}
