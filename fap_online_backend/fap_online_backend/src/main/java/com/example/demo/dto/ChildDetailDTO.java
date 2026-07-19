package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChildDetailDTO {
    private Integer studentId;
    private String studentCode;
    private String fullName;
    private String email;
    private String phone;
    private LocalDate dateOfBirth;
    private String gender;
    private String avatarUrl;
    private String major;
    private Integer enrollmentYear;
    private String academicStatus;
}
