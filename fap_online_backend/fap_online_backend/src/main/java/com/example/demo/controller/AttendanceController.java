package com.example.demo.controller;

import com.example.demo.dto.AttendanceRequestDTO;
import com.example.demo.dto.AttendanceStudentDTO;
import com.example.demo.service.AttendanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/attendance")
@CrossOrigin(origins = "*")
public class AttendanceController {

    @Autowired
    private AttendanceService attendanceService;

    // Lấy danh sách sinh viên của một buổi học
    @GetMapping("/{scheduleId}")
    public List<AttendanceStudentDTO> getAttendanceBySchedule(
            @PathVariable Integer scheduleId) {

        return attendanceService.getAttendanceBySchedule(
                scheduleId
        );
    }

    // Lưu điểm danh
    @PostMapping("/save")
    public String saveAttendance(
            @RequestBody AttendanceRequestDTO request) {

        attendanceService.saveAttendance(request);

        return "Attendance saved successfully";
    }

}