package com.example.demo.controller;

import com.example.demo.dto.AttendanceRequestDTO;
import com.example.demo.dto.AttendanceStudentDTO;
import com.example.demo.service.TeacherAttendanceService;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/attendance")
@CrossOrigin(origins = "*")
public class TeacherAttendanceController {

	private final TeacherAttendanceService teacherAttendanceService;

	public TeacherAttendanceController(TeacherAttendanceService teacherAttendanceService) {
		this.teacherAttendanceService = teacherAttendanceService;
	}

	@GetMapping("/{scheduleId}")
	public List<AttendanceStudentDTO> getAttendanceBySchedule(@PathVariable Integer scheduleId) {
		return teacherAttendanceService.getAttendanceBySchedule(scheduleId);
	}

	@PostMapping("/save")
	public String saveAttendance(@RequestBody AttendanceRequestDTO request) {
		teacherAttendanceService.saveAttendance(request);
		return "Attendance saved successfully";
	}
}
