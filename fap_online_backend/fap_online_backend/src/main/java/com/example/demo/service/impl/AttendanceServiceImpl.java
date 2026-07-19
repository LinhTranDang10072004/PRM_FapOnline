package com.example.demo.service.impl;

import com.example.demo.dto.AttendanceReportDTO;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import com.example.demo.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AttendanceServiceImpl implements AttendanceService {
    
    private final AttendanceRepository attendanceRepository;
    private final ScheduleRepository scheduleRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    private final TimeSlotRepository timeSlotRepository;
    
    @Override
    public List<AttendanceReportDTO> getAttendanceReport(
        Integer studentId, 
        LocalDate startDate, 
        LocalDate endDate) {
        
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(23, 59, 59);
        
        List<Attendance> attendances = 
            attendanceRepository.findByStudentAndDateRange(
                studentId, start, end
            );
        
        return attendances.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<AttendanceReportDTO> getMonthlyAttendance(
        Integer studentId,
        Integer month,
        Integer year) {
        
        List<Attendance> attendances = 
            attendanceRepository.findMonthlyAttendance(
                studentId, year, month
            );
        
        return attendances.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public Map<String, Long> getAttendanceStats(Integer studentId) {
        // Get all attendances for student
        List<Attendance> allAttendances = attendanceRepository.findAll()
            .stream()
            .filter(a -> a.getStudentId().equals(studentId))
            .collect(Collectors.toList());
        
        // Group by status and count
        return allAttendances.stream()
            .collect(Collectors.groupingBy(
                Attendance::getStatus,
                Collectors.counting()
            ));
    }
    
    private AttendanceReportDTO mapToDTO(Attendance attendance) {
        Schedule schedule = scheduleRepository
            .findById(attendance.getScheduleId())
            .orElse(null);
        
        String subjectCode = "";
        String timeSlot = "";
        
        if (schedule != null) {
            SchoolClass schoolClass = schoolClassRepository
                .findById(schedule.getClassId())
                .orElse(null);
            
            if (schoolClass != null) {
                Subject subject = subjectRepository
                    .findById(schoolClass.getSubjectId())
                    .orElse(null);
                
                subjectCode = subject != null 
                    ? subject.getSubjectCode() 
                    : "";
            }
            
            TimeSlot ts = timeSlotRepository
                .findById(schedule.getTimeSlotId())
                .orElse(null);
            
            timeSlot = ts != null 
                ? ts.getStartTime() + " - " + ts.getEndTime() 
                : "";
        }
        
        return AttendanceReportDTO.builder()
            .subjectCode(subjectCode)
            .date(attendance.getMarkedAt().toLocalDate())
            .timeSlot(timeSlot)
            .status(attendance.getStatus())
            .build();
    }
}
