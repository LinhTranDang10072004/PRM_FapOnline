package com.example.demo.service.impl;

import com.example.demo.entity.Parent;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.repository.ParentRepository;
import com.example.demo.repository.ParentStudentRepository;
import com.example.demo.service.ParentValidationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import com.example.demo.util.SecurityUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ParentValidationServiceImpl implements ParentValidationService {

    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;

    @Override
    public void validateParentOwnsStudent(Integer studentId) {
        Integer parentUserId = SecurityUtils.extractUserId();
        Parent parent = parentRepository.findByUserId(parentUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Parent profile not found"));
                
        List<Integer> studentIds = parentStudentRepository.findStudentIdsByParentId(parent.getParentId());
        
        if (!studentIds.contains(studentId)) {
            throw new AccessDeniedException("Access denied: You do not have permission to view data for this student.");
        }
    }
}
