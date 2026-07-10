package com.example.demo.service;

import com.example.demo.dto.*;

import java.util.List;

import java.time.LocalDate;

public interface ParentChildService {
    List<ChildDetailDTO> getMyChildren();
    
    ChildDetailDTO getChildDetail(Integer studentId);
    
    List<WeeklyTimetableDTO> getChildTimetable(Integer studentId, LocalDate week);
    
    List<AttendanceReportDTO> getChildAttendance(Integer studentId, Integer subjectId, Integer semesterId);
    
    List<GradeReportDTO> getChildGrades(Integer studentId, Integer semesterId);
    
    List<TranscriptDTO> getChildTranscript(Integer studentId);
    
    List<FeeDTO> getChildFees(Integer studentId, Integer semesterId);
}
