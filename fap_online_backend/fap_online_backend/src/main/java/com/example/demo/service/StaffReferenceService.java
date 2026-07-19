package com.example.demo.service;

import com.example.demo.dto.StudentDTO;
import com.example.demo.dto.TeacherDTO;
import java.util.List;

public interface StaffReferenceService {
    List<TeacherDTO> getActiveTeachers();
    List<StudentDTO> getActiveStudents();
}
