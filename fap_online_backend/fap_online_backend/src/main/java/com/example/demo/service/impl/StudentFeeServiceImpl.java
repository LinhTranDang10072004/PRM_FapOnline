package com.example.demo.service.impl;

import com.example.demo.dto.StudentFeeDTO;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import com.example.demo.service.StudentFeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StudentFeeServiceImpl implements StudentFeeService {
    
    private final StudentFeeRepository studentFeeRepository;
    private final FeeTypeRepository feeTypeRepository;
    private final SemesterRepository semesterRepository;
    
    @Override
    public List<StudentFeeDTO> getStudentFees(Integer studentId) {
        List<StudentFee> fees = studentFeeRepository
            .findByStudentId(studentId);
        
        return fees.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<StudentFeeDTO> getUnpaidFees(Integer studentId) {
        List<StudentFee> fees = studentFeeRepository
            .findByStudentId(studentId)
            .stream()
            .filter(f -> "UNPAID".equals(f.getStatus()))
            .collect(Collectors.toList());
        
        return fees.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<StudentFeeDTO> getOverdueFees(Integer studentId) {
        List<StudentFee> fees = studentFeeRepository
            .findOverdueFees(studentId);
        
        return fees.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<StudentFeeDTO> getFeesBySemester(
        Integer studentId,
        Integer semesterId) {
        
        List<StudentFee> fees = studentFeeRepository
            .findByStudentAndSemester(studentId, semesterId);
        
        return fees.stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    public BigDecimal getTotalUnpaidAmount(Integer studentId) {
        List<StudentFee> unpaidFees = studentFeeRepository
            .findByStudentId(studentId)
            .stream()
            .filter(f -> "UNPAID".equals(f.getStatus()))
            .collect(Collectors.toList());
        
        return unpaidFees.stream()
            .map(fee -> fee.getAmount().subtract(fee.getPaidAmount()))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    private StudentFeeDTO mapToDTO(StudentFee fee) {
        FeeType feeType = feeTypeRepository
            .findById(fee.getFeeTypeId())
            .orElse(null);
        
        Semester semester = semesterRepository
            .findById(fee.getSemesterId())
            .orElse(null);
        
        BigDecimal remaining = fee.getAmount()
            .subtract(fee.getPaidAmount());
        
        return StudentFeeDTO.builder()
            .studentFeeId(fee.getStudentFeeId())
            .feeTypeName(feeType != null 
                ? feeType.getFeeTypeName() 
                : "")
            .amount(fee.getAmount())
            .paidAmount(fee.getPaidAmount())
            .remainingAmount(remaining)
            .dueDate(fee.getDueDate())
            .status(fee.getStatus())
            .semesterName(semester != null 
                ? semester.getSemesterName() 
                : "")
            .build();
    }
}
