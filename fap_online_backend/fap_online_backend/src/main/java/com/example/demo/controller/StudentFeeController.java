package com.example.demo.controller;

import com.example.demo.dto.StudentFeeDTO;
import com.example.demo.service.StudentFeeService;
import com.example.demo.service.ParentValidationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/fees")
@RequiredArgsConstructor
@Tag(name = "Student Fees", description = "Student fees endpoints")
@PreAuthorize("hasRole('PARENT')")
public class StudentFeeController {
    
    private final StudentFeeService studentFeeService;
    private final ParentValidationService parentValidationService;
    
    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<StudentFeeDTO>> getStudentFees(
        @PathVariable Integer studentId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            studentFeeService.getStudentFees(studentId)
        );
    }
    
    @GetMapping("/unpaid/{studentId}")
    public ResponseEntity<List<StudentFeeDTO>> getUnpaidFees(
        @PathVariable Integer studentId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            studentFeeService.getUnpaidFees(studentId)
        );
    }
    
    @GetMapping("/overdue/{studentId}")
    public ResponseEntity<List<StudentFeeDTO>> getOverdueFees(
        @PathVariable Integer studentId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            studentFeeService.getOverdueFees(studentId)
        );
    }
    
    @GetMapping("/semester/{studentId}/{semesterId}")
    public ResponseEntity<List<StudentFeeDTO>> getFeesBySemester(
        @PathVariable Integer studentId,
        @PathVariable Integer semesterId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            studentFeeService.getFeesBySemester(studentId, semesterId)
        );
    }
    
    @GetMapping("/total-unpaid/{studentId}")
    public ResponseEntity<BigDecimal> getTotalUnpaid(
        @PathVariable Integer studentId
    ) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return ResponseEntity.ok(
            studentFeeService.getTotalUnpaidAmount(studentId)
        );
    }
}
