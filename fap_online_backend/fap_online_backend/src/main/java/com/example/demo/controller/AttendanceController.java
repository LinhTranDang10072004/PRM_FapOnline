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
@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
@Tag(name = "Attendance", description = "Student attendance endpoints")
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
        return ResponseEntity.ok(
            attendanceService.getAttendanceStats(studentId)
        );
    }
}
