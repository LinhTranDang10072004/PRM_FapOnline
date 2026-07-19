package com.example.demo.service;

import com.example.demo.dto.*;

import java.util.List;

public interface StaffClassService {

    List<ClassDTO> getAllClasses(Integer semesterId);

    ClassDTO getClassById(Integer classId);

    ClassDTO createClass(CreateClassRequest request);

    ClassDTO updateClass(Integer classId, UpdateClassRequest request);

    ClassDTO cancelClass(Integer classId);

    ClassDTO assignTeacher(Integer classId, AssignTeacherRequest request);

    List<ClassStudentDTO> getClassStudents(Integer classId);

    ClassStudentDTO addStudentToClass(Integer classId, AddStudentToClassRequest request);

    void removeStudentFromClass(Integer classId, Integer studentId);
}