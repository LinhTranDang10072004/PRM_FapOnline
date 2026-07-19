package com.example.demo.dto;

import java.util.List;

public class TranscriptDto {
    private String semesterName;
    private List<GradeDto> subjects;

    public String getSemesterName() { return semesterName; }
    public void setSemesterName(String semesterName) { this.semesterName = semesterName; }
    public List<GradeDto> getSubjects() { return subjects; }
    public void setSubjects(List<GradeDto> subjects) { this.subjects = subjects; }
}
