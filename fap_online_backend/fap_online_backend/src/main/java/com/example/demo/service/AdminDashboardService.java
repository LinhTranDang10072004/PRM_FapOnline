package com.example.demo.service;

import com.example.demo.dto.AdminDashboardDTO;
import com.example.demo.dto.AdminSemesterDTO;

import java.util.List;

public interface AdminDashboardService {

    AdminDashboardDTO getDashboard(String academicYear, String term);

    List<AdminSemesterDTO> getSemesters();

    List<String> getAcademicYears();
}
