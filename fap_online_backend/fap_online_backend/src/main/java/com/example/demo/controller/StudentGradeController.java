package com.example.demo.controller;

import com.example.demo.dto.GradeItemDTO;
import com.example.demo.entity.StudentGrade;
import com.example.demo.service.StudentGradeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/student-grades")
@CrossOrigin(origins = "*")
public class StudentGradeController {


    private final StudentGradeService studentGradeService;


    public StudentGradeController(StudentGradeService studentGradeService) {
        this.studentGradeService = studentGradeService;
    }



    // ==========================================
    // TEACHER - VIEW CLASS GRADE
    // ==========================================

    // Teacher xem toàn bộ bảng điểm của lớp
    @GetMapping("/class/{classId}/{teacherId}")
    public ResponseEntity<List<GradeItemDTO>> getGradeItemsByClass(
            @PathVariable Integer classId,
            @PathVariable Integer teacherId
    ) {

        return ResponseEntity.ok(
                studentGradeService
                        .getGradeItemsByClassId(
                                classId,
                                teacherId
                        )
        );

    }





    // ==========================================
    // STUDENT - VIEW GRADE
    // ==========================================

    // Sinh viên xem điểm của mình
    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<StudentGrade>> getGradesByStudent(
            @PathVariable Integer studentId
    ) {

        return ResponseEntity.ok(
                studentGradeService
                        .getGradesByStudentId(studentId)
        );
    }




    // ==========================================
    // FIND GRADE BY ID
    // ==========================================

    @GetMapping("/{id}")
    public ResponseEntity<StudentGrade> getGradeById(
            @PathVariable Integer id
    ) {

        return ResponseEntity.ok(
                studentGradeService
                        .getGradeById(id)
        );
    }





    // ==========================================
    // CREATE / UPDATE GRADE
    // ==========================================

    // Teacher nhập hoặc sửa điểm
    @PostMapping
    public ResponseEntity<StudentGrade> saveGrade(
            @RequestBody StudentGrade grade
    ) {

        return ResponseEntity.ok(
                studentGradeService
                        .saveGrade(grade)
        );
    }





    // ==========================================
    // DELETE
    // ==========================================

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteGrade(
            @PathVariable Integer id
    ) {


        studentGradeService.deleteGrade(id);


        return ResponseEntity.ok(
                "Delete grade successfully"
        );

    }
    @PutMapping("/{id}")
    public ResponseEntity<StudentGrade> updateGrade(
            @PathVariable Integer id,
            @RequestBody StudentGrade grade
    ) {

        StudentGrade oldGrade = studentGradeService.getGradeById(id);

        oldGrade.setScore(grade.getScore());
        oldGrade.setStatus(grade.getStatus());

        return ResponseEntity.ok(
                studentGradeService.saveGrade(oldGrade)
        );
    }

}