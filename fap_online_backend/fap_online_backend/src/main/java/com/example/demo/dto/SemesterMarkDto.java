package com.example.demo.dto;

import java.util.ArrayList;
import java.util.List;

public class SemesterMarkDto {
    private Integer semesterId;
    private String semesterCode;
    private String semesterName;
    private List<CourseMarkSummaryDto> courses = new ArrayList<>();

    public Integer getSemesterId() { return semesterId; }
    public void setSemesterId(Integer semesterId) { this.semesterId = semesterId; }
    public String getSemesterCode() { return semesterCode; }
    public void setSemesterCode(String semesterCode) { this.semesterCode = semesterCode; }
    public String getSemesterName() { return semesterName; }
    public void setSemesterName(String semesterName) { this.semesterName = semesterName; }
    public List<CourseMarkSummaryDto> getCourses() { return courses; }
    public void setCourses(List<CourseMarkSummaryDto> courses) { this.courses = courses; }
}
