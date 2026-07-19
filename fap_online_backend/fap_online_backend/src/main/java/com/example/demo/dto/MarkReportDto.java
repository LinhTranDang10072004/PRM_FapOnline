package com.example.demo.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class MarkReportDto {
    private List<SemesterMarkDto> semesters = new ArrayList<>();

    public List<SemesterMarkDto> getSemesters() { return semesters; }
    public void setSemesters(List<SemesterMarkDto> semesters) { this.semesters = semesters; }
}
