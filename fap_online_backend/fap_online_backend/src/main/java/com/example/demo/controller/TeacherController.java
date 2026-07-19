package com.example.demo.controller;


import com.example.demo.dto.TeacherClassDTO;
import com.example.demo.dto.TeacherDashboardResponse;
import com.example.demo.dto.TeacherScheduleDTO;
import com.example.demo.dto.ClassStudentDTO;
import com.example.demo.entity.Teacher;
import com.example.demo.service.TeacherService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/api/teacher")
@CrossOrigin(origins = "*")
public class TeacherController {


    @Autowired
    private TeacherService teacherService;



    // Lấy thông tin giáo viên theo UserId
    @GetMapping("/{userId}")
    public ResponseEntity<?> getTeacherByUserId(
            @PathVariable Integer userId) {


        Optional<Teacher> teacher =
                teacherService.getTeacherByUserId(userId);



        if(teacher.isPresent()){

            return ResponseEntity.ok(
                    teacher.get()
            );

        }


        return ResponseEntity.notFound().build();

    }




    // Dashboard giáo viên
    @GetMapping("/dashboard/{userId}")
    public ResponseEntity<TeacherDashboardResponse> getDashboard(
            @PathVariable Integer userId) {


        TeacherDashboardResponse dashboard =
                teacherService.getTeacherDashboard(userId);



        return ResponseEntity.ok(dashboard);

    }
    @GetMapping("/schedule/{userId}")
    public ResponseEntity<List<TeacherScheduleDTO>> getTeacherSchedule(
            @PathVariable Integer userId) {

        return ResponseEntity.ok(
                teacherService.getTeacherSchedule(userId)
        );

    }
    @GetMapping("/classes/{userId}")
    public ResponseEntity<List<TeacherClassDTO>> getTeacherClasses(
            @PathVariable Integer userId
    ){

        return ResponseEntity.ok(
                teacherService.getTeacherClasses(userId)
        );

    }

    @GetMapping("/classes/{userId}/{classId}/students")
    public ResponseEntity<List<ClassStudentDTO>> getClassStudents(
            @PathVariable Integer userId,
            @PathVariable Integer classId
    ) {
        return ResponseEntity.ok(teacherService.getClassStudents(userId, classId));
    }


}