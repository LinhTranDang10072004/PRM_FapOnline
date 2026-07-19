package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.security.AuthenticatedUser;
import com.example.demo.service.StudentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/student")
public class StudentController {

	private final StudentService studentService;

	public StudentController(StudentService studentService) {
		this.studentService = studentService;
	}

	@GetMapping("/timetable")
	public ResponseEntity<StudentWeeklyTimetableDto> getTimetable(
			@AuthenticationPrincipal AuthenticatedUser user,
			@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
			@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate) {
		return ResponseEntity.ok(studentService.getWeeklyTimetable(user.getUserId(), fromDate, toDate));
	}

	@GetMapping("/marks")
	public ResponseEntity<List<GradeDto>> getMarks(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentService.getMarkReport(user.getUserId()));
	}

	@GetMapping("/attendance")
	public ResponseEntity<List<AttendanceDto>> getAttendance(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentService.getAttendanceReport(user.getUserId()));
	}

	@GetMapping("/transcript")
	public ResponseEntity<StudentTranscriptDto> getTranscript(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentService.getAcademicTranscript(user.getUserId()));
	}

	@GetMapping("/classes")
	public ResponseEntity<List<StudentClassDto>> getMyClasses(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentService.getMyClasses(user.getUserId()));
	}

	@GetMapping("/dashboard")
	public ResponseEntity<DashboardSummaryDto> getDashboardSummary(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentService.getDashboardSummary(user.getUserId()));
	}

	@GetMapping("/notifications")
	public ResponseEntity<List<StudentNotificationDto>> getNotifications(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentService.getNotifications(user.getUserId()));
	}
}
