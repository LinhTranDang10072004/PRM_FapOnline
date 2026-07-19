package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClassStudentDTO {
    private Integer studentId;
    private String studentCode;
    private String fullName;
    private LocalDateTime enrolledAt;
    private String status;
}