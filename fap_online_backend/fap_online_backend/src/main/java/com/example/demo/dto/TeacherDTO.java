package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TeacherDTO {
    private Integer teacherId;
    private String teacherCode;
    private String fullName;
    private String department;
}
