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
public class StudentClassDto {
	private Integer classId;
	private String classCode;
	private String className;
	private String subjectCode;
	private String subjectName;
	private String status;
	private LocalDateTime enrolledAt;
}
