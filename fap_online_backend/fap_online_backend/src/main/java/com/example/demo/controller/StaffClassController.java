package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.service.StaffClassService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/staff/classes")
@RequiredArgsConstructor
@Tag(name = "Staff - Classes", description = "UC-13/14/15: Quản lý lớp học, sinh viên, giáo viên")
@PreAuthorize("hasAnyRole('STAFF','ADMIN')")
public class StaffClassController {

    private final StaffClassService staffClassService;

    @GetMapping
    @Operation(summary = "Danh sách lớp học", description = "Có thể lọc theo học kỳ bằng query param semesterId")
    public ResponseEntity<List<ClassDTO>> getAllClasses(
            @Parameter(description = "Lọc theo ID học kỳ (tùy chọn)") @RequestParam(required = false) Integer semesterId) {
        return ResponseEntity.ok(staffClassService.getAllClasses(semesterId));
    }

    @GetMapping("/{classId}")
    @Operation(summary = "Chi tiết lớp học")
    public ResponseEntity<ClassDTO> getClassById(@PathVariable Integer classId) {
        return ResponseEntity.ok(staffClassService.getClassById(classId));
    }

    @PostMapping
    @Operation(summary = "Tạo lớp học mới")
    public ResponseEntity<ClassDTO> createClass(@Valid @RequestBody CreateClassRequest request) {
        return ResponseEntity.ok(staffClassService.createClass(request));
    }

    @PutMapping("/{classId}")
    @Operation(summary = "Cập nhật lớp học")
    public ResponseEntity<ClassDTO> updateClass(@PathVariable Integer classId, @Valid @RequestBody UpdateClassRequest request) {
        return ResponseEntity.ok(staffClassService.updateClass(classId, request));
    }

    @DeleteMapping("/{classId}")
    @Operation(summary = "Hủy lớp học (soft delete)", description = "Chuyển trạng thái lớp sang Cancelled. Hệ thống không bao giờ xóa cứng lớp học.")
    public ResponseEntity<ClassDTO> cancelClass(@PathVariable Integer classId) {
        return ResponseEntity.ok(staffClassService.cancelClass(classId));
    }

    @PutMapping("/{classId}/teacher")
    @Operation(summary = "Phân công giáo viên chính cho lớp")
    public ResponseEntity<ClassDTO> assignTeacher(@PathVariable Integer classId, @Valid @RequestBody AssignTeacherRequest request) {
        return ResponseEntity.ok(staffClassService.assignTeacher(classId, request));
    }

    @GetMapping("/{classId}/students")
    @Operation(summary = "Danh sách sinh viên trong lớp")
    public ResponseEntity<List<ClassStudentDTO>> getClassStudents(@PathVariable Integer classId) {
        return ResponseEntity.ok(staffClassService.getClassStudents(classId));
    }

    @PostMapping("/{classId}/students")
    @Operation(summary = "Thêm sinh viên vào lớp")
    public ResponseEntity<ClassStudentDTO> addStudentToClass(@PathVariable Integer classId, @Valid @RequestBody AddStudentToClassRequest request) {
        return ResponseEntity.ok(staffClassService.addStudentToClass(classId, request));
    }

    @DeleteMapping("/{classId}/students/{studentId}")
    @Operation(summary = "Xóa sinh viên khỏi lớp", description = "Chỉ xóa được nếu sinh viên chưa có điểm/điểm danh trong lớp")
    public ResponseEntity<Void> removeStudentFromClass(@PathVariable Integer classId, @PathVariable Integer studentId) {
        staffClassService.removeStudentFromClass(classId, studentId);
        return ResponseEntity.noContent().build();
    }
}