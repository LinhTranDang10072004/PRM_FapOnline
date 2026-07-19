package com.example.demo.service;

import com.example.demo.dto.StudentFeeDTO;
import java.math.BigDecimal;
import java.util.List;

public interface StudentFeeService {
    
    /**
     * Get all fees for student
     */
    List<StudentFeeDTO> getStudentFees(Integer studentId);
    
    /**
     * Get unpaid fees
     */
    List<StudentFeeDTO> getUnpaidFees(Integer studentId);
    
    /**
     * Get overdue fees
     */
    List<StudentFeeDTO> getOverdueFees(Integer studentId);
    
    /**
     * Get fees by semester
     */
    List<StudentFeeDTO> getFeesBySemester(
        Integer studentId,
        Integer semesterId
    );
    
    /**
     * Calculate total unpaid amount
     */
    BigDecimal getTotalUnpaidAmount(Integer studentId);
}
