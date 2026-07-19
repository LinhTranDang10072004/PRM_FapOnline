package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StudentDTO {
    private Integer studentId;
    private String studentCode;
    private String fullName;
    private String major;
}
