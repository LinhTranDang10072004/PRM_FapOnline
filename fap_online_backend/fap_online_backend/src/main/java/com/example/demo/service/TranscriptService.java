package com.example.demo.service;

import com.example.demo.dto.TranscriptDTO;
import java.math.BigDecimal;
import java.util.List;

public interface TranscriptService {
    
    /**
     * Get full transcript for student
     */
    List<TranscriptDTO> getStudentTranscript(Integer studentId);
    
    /**
     * Get recent grades
     */
    List<TranscriptDTO> getRecentGrades(
        Integer studentId, 
        Integer limit
    );
    
    /**
     * Get semester transcript
     */
    List<TranscriptDTO> getSemesterTranscript(
        Integer studentId,
        Integer semesterId
    );
    
    /**
     * Get average score for student
     */
    BigDecimal getAverageScore(Integer studentId);
}
