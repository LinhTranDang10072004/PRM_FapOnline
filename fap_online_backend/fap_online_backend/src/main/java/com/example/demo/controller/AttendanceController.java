package com.example.demo.controller;

import com.example.demo.dto.AttendanceReportDTO;
import com.example.demo.service.AttendanceService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
@Tag(name = "Attendance", description = "Student attendance endpoints")
@PreAuthorize("hasRole('PARENT')")
public class AttendanceController {
    
    private final AttendanceService attendanceService;
    
    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<AttendanceReportDTO>> getStudentAttendance(
        @PathVariable Integer studentId,
        @RequestParam LocalDate startDate,
        @RequestParam LocalDate endDate
    ) {
        return ResponseEntity.ok(
            attendanceService.getAttendanceReport(
                studentId, startDate, endDate
            )
        );
    }
    
    @GetMapping("/monthly/{studentId}")
    public ResponseEntity<List<AttendanceReportDTO>> getMonthlyAttendance(
        @PathVariable Integer studentId,
        @RequestParam Integer month,
        @RequestParam Integer year
    ) {
        return ResponseEntity.ok(
            attendanceService.getMonthlyAttendance(studentId, month, year)
        );
    }
    
    @GetMapping("/stats/{studentId}")
    public ResponseEntity<Map<String, Long>> getAttendanceStats(
        @PathVariable Integer studentId
    ) {
        return ResponseEntity.ok(
            attendanceService.getAttendanceStats(studentId)
        );
    }
}
