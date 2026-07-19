package com.example.demo.service.impl;

import com.example.demo.dto.AdminDashboardDTO;
import com.example.demo.repository.SchoolClassRepository;
import com.example.demo.repository.StudentRepository;
import com.example.demo.repository.SubjectRepository;
import com.example.demo.repository.TeacherRepository;
import com.example.demo.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminDashboardServiceImpl implements AdminDashboardService {

    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;

    @Override
    public AdminDashboardDTO getDashboard() {
        return AdminDashboardDTO.builder()
                .totalStudents(studentRepository.count())
                .totalTeachers(teacherRepository.count())
                .totalClasses(schoolClassRepository.count())
                .totalSubjects(subjectRepository.count())
                .build();
    }
}
