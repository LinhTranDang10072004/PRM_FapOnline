package com.example.demo.controller;

import com.example.demo.dto.TranscriptDTO;
import com.example.demo.service.TranscriptService;
import com.example.demo.service.ParentValidationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/transcript")
@RequiredArgsConstructor
@Tag(name = "Transcript", description = "Student transcript/grades endpoints")
@PreAuthorize("hasRole('PARENT')")
public class TranscriptController {
    
    private final TranscriptService transcriptService;
    private final ParentValidationService parentValidationService;
    
    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<TranscriptDTO>> getStudentTranscript(
        @PathVariable Integer studentId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            transcriptService.getStudentTranscript(studentId)
        );
    }
    
    @GetMapping("/recent/{studentId}")
    public ResponseEntity<List<TranscriptDTO>> getRecentGrades(
        @PathVariable Integer studentId,
        @RequestParam(defaultValue = "5") Integer limit
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            transcriptService.getRecentGrades(studentId, limit)
        );
    }
    
    @GetMapping("/semester/{studentId}/{semesterId}")
    public ResponseEntity<List<TranscriptDTO>> getSemesterTranscript(
        @PathVariable Integer studentId,
        @PathVariable Integer semesterId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            transcriptService.getSemesterTranscript(studentId, semesterId)
        );
    }
    
    @GetMapping("/average/{studentId}")
    public ResponseEntity<BigDecimal> getAverageScore(
        @PathVariable Integer studentId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            transcriptService.getAverageScore(studentId)
        );
    }
}
