package com.example.demo.controller;

import com.example.demo.dto.StudentDTO;
import com.example.demo.dto.TeacherDTO;
import com.example.demo.service.StaffReferenceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/staff/references")
@RequiredArgsConstructor
@Tag(name = "Staff References", description = "Lấy dữ liệu danh mục cho Staff (Giáo viên, Sinh viên, v.v.)")
public class StaffReferenceController {

    private final StaffReferenceService staffReferenceService;

    @GetMapping("/teachers")
    @Operation(summary = "Lấy danh sách giáo viên", description = "Trả về danh sách giáo viên đang có trạng thái Active")
    public ResponseEntity<List<TeacherDTO>> getActiveTeachers() {
        return ResponseEntity.ok(staffReferenceService.getActiveTeachers());
    }

    @GetMapping("/students")
    @Operation(summary = "Lấy danh sách sinh viên", description = "Trả về danh sách sinh viên đang có trạng thái Active")
    public ResponseEntity<List<StudentDTO>> getActiveStudents() {
        return ResponseEntity.ok(staffReferenceService.getActiveStudents());
    }
}
