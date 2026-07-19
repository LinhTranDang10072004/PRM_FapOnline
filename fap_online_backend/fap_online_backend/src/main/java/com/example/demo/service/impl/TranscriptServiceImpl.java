package com.example.demo.service.impl;

import com.example.demo.dto.TranscriptDTO;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import com.example.demo.service.TranscriptService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TranscriptServiceImpl implements TranscriptService {
    
    private final StudentGradeRepository studentGradeRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    
    @Override
    public List<TranscriptDTO> getStudentTranscript(Integer studentId) {
        List<StudentGrade> grades = 
            studentGradeRepository.findPublishedGradesByStudent(studentId);
        
        return grades.stream()
            .map(this::mapToDTO)
            .distinct()
            .collect(Collectors.toList());
    }
    
    @Override
    public List<TranscriptDTO> getRecentGrades(
        Integer studentId, 
        Integer limit) {
        
        List<StudentGrade> grades = 
            studentGradeRepository.findPublishedGradesByStudent(studentId);
        
        return grades.stream()
            .limit(limit != null ? limit : 5)
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<TranscriptDTO> getSemesterTranscript(
        Integer studentId,
        Integer semesterId) {
        
        List<StudentGrade> grades = 
            studentGradeRepository.findBySemester(studentId, semesterId);
        
        return grades.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public BigDecimal getAverageScore(Integer studentId) {
        List<StudentGrade> grades = 
            studentGradeRepository.findPublishedGradesByStudent(studentId);
        
        if (grades.isEmpty()) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal sum = grades.stream()
            .map(StudentGrade::getScore)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return sum.divide(
            new BigDecimal(grades.size()), 
            2, 
            RoundingMode.HALF_UP
        );
    }
    
    private TranscriptDTO mapToDTO(StudentGrade grade) {
        SchoolClass schoolClass = schoolClassRepository
            .findById(grade.getClassId())
            .orElse(null);
        
        String subjectCode = "";
        String subjectName = "";
        
        if (schoolClass != null) {
            Subject subject = subjectRepository
                .findById(schoolClass.getSubjectId())
                .orElse(null);
            
            if (subject != null) {
                subjectCode = subject.getSubjectCode();
                subjectName = subject.getSubjectName();
            }
        }
        
        return TranscriptDTO.builder()
            .subjectCode(subjectCode)
            .subjectName(subjectName)
            .finalScore(grade.getScore())
            .status(grade.getStatus())
            .build();
    }
}
