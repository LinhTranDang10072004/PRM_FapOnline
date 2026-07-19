package com.example.demo.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChildSummaryDTO {
    private Integer studentId;
    private String studentCode;
    private String fullName;
    private String major;
    private String academicStatus;
}
