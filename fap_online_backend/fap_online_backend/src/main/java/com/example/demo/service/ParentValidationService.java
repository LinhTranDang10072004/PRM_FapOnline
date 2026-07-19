package com.example.demo.service;

public interface ParentValidationService {
    /**
     * Validates if the authenticated parent has access to the specified student.
     * @param parentUserId The user ID of the authenticated parent.
     * @param studentId The ID of the student to access.
     * @throws org.springframework.security.access.AccessDeniedException if no access.
     */
    void validateParentOwnsStudent(Integer studentId);
}
