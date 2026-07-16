package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClassDTO {
    private Integer classId;
    private String classCode;
    private String className;
    private Integer subjectId;
    private String subjectCode;
    private String subjectName;
    private Integer semesterId;
    private String semesterName;
    private Integer teacherId;
    private String teacherName;
    private Integer maxStudents;
    private Integer currentStudents;
    private String status;
}