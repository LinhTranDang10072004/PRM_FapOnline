package com.example.demo.service.impl;

import com.example.demo.dto.StudentDTO;
import com.example.demo.dto.TeacherDTO;
import com.example.demo.entity.Student;
import com.example.demo.entity.Teacher;
import com.example.demo.entity.User;
import com.example.demo.repository.StudentRepository;
import com.example.demo.repository.TeacherRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.StaffReferenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StaffReferenceServiceImpl implements StaffReferenceService {

    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;

    @Override
    public List<TeacherDTO> getActiveTeachers() {
        List<Teacher> teachers = teacherRepository.findAll();
        List<Integer> userIds = teachers.stream().map(Teacher::getUserId).collect(Collectors.toList());
        Map<Integer, User> userMap = userRepository.findAllById(userIds).stream()
                .filter(u -> "Active".equalsIgnoreCase(u.getStatus()))
                .collect(Collectors.toMap(User::getUserId, u -> u));

        return teachers.stream()
                .filter(t -> userMap.containsKey(t.getUserId()))
                .map(t -> {
                    User u = userMap.get(t.getUserId());
                    return TeacherDTO.builder()
                            .teacherId(t.getTeacherId())
                            .teacherCode(t.getTeacherCode())
                            .fullName(u.getFullName())
                            .department(t.getDepartment())
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Override
    public List<StudentDTO> getActiveStudents() {
        List<Student> students = studentRepository.findAll();
        List<Integer> userIds = students.stream().map(Student::getUserId).collect(Collectors.toList());
        Map<Integer, User> userMap = userRepository.findAllById(userIds).stream()
                .filter(u -> "Active".equalsIgnoreCase(u.getStatus()))
                .collect(Collectors.toMap(User::getUserId, u -> u));

        return students.stream()
                .filter(s -> userMap.containsKey(s.getUserId()))
                .map(s -> {
                    User u = userMap.get(s.getUserId());
                    return StudentDTO.builder()
                            .studentId(s.getStudentId())
                            .studentCode(s.getStudentCode())
                            .fullName(u.getFullName())
                            .major(s.getMajor())
                            .build();
                })
                .collect(Collectors.toList());
    }
}
