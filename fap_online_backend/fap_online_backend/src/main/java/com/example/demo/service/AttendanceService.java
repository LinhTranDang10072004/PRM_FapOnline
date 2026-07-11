package com.example.demo.service;

import com.example.demo.dto.AttendanceReportDTO;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface AttendanceService {
    
    /**
     * Get attendance report for student in date range
     */
    List<AttendanceReportDTO> getAttendanceReport(
        Integer studentId, 
        LocalDate startDate, 
        LocalDate endDate
    );
    
    /**
     * Get monthly attendance summary
     */
    List<AttendanceReportDTO> getMonthlyAttendance(
        Integer studentId,
        Integer month,
        Integer year
    );
    
    /**
     * Get attendance statistics (count by status)
     */
    Map<String, Long> getAttendanceStats(
        Integer studentId
    );
}
