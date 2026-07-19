package com.example.demo.controller;

import com.example.demo.dto.AttendanceReportDTO;
import com.example.demo.service.AttendanceService;
import com.example.demo.service.ParentValidationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
@Tag(name = "Attendance", description = "Parent attendance report endpoints")
@PreAuthorize("hasRole('PARENT')")
public class AttendanceController {

	private final AttendanceService attendanceService;
	private final ParentValidationService parentValidationService;

	@GetMapping("/student/{studentId}")
	public ResponseEntity<List<AttendanceReportDTO>> getStudentAttendance(
			@PathVariable Integer studentId,
			@RequestParam LocalDate startDate,
			@RequestParam LocalDate endDate
	) {
		parentValidationService.validateParentOwnsStudent(studentId);
		return ResponseEntity.ok(
				attendanceService.getAttendanceReport(studentId, startDate, endDate)
		);
	}

	@GetMapping("/monthly/{studentId}")
	public ResponseEntity<List<AttendanceReportDTO>> getMonthlyAttendance(
			@PathVariable Integer studentId,
			@RequestParam Integer month,
			@RequestParam Integer year
	) {
		parentValidationService.validateParentOwnsStudent(studentId);
		return ResponseEntity.ok(
				attendanceService.getMonthlyAttendance(studentId, month, year)
		);
	}

	@GetMapping("/stats/{studentId}")
	public ResponseEntity<Map<String, Long>> getAttendanceStats(
			@PathVariable Integer studentId
	) {
		parentValidationService.validateParentOwnsStudent(studentId);
		return ResponseEntity.ok(attendanceService.getAttendanceStats(studentId));
	}
}
