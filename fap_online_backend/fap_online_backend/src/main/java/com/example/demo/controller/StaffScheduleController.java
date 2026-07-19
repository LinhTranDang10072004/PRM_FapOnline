package com.example.demo.controller;

import com.example.demo.dto.CreateScheduleRequest;
import com.example.demo.dto.ScheduleDTO;
import com.example.demo.dto.UpdateScheduleRequest;
import com.example.demo.service.StaffScheduleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/staff/schedules")
@RequiredArgsConstructor
@Tag(name = "Staff - Schedules")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('STAFF')")
public class StaffScheduleController {

    private final StaffScheduleService staffScheduleService;

    @GetMapping
    @Operation(summary = "Danh sách lịch học", description = "Lọc tùy chọn theo classId và/hoặc date (yyyy-MM-dd)")
    public ResponseEntity<List<ScheduleDTO>> getSchedules(
            @RequestParam(required = false) Integer classId,
            @Parameter(description = "Định dạng yyyy-MM-dd")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(staffScheduleService.getSchedules(classId, date));
    }

    @GetMapping("/{scheduleId}")
    @Operation(summary = "Chi tiết lịch học")
    public ResponseEntity<ScheduleDTO> getScheduleById(@PathVariable Integer scheduleId) {
        return ResponseEntity.ok(staffScheduleService.getScheduleById(scheduleId));
    }

    @PostMapping
    @Operation(summary = "Tạo lịch học mới", description = "Kiểm tra trùng phòng, trùng giáo viên, trùng sinh viên và khoảng thời gian học kỳ")
    public ResponseEntity<ScheduleDTO> createSchedule(@Valid @RequestBody CreateScheduleRequest request) {
        return ResponseEntity.ok(staffScheduleService.createSchedule(request));
    }

    @PutMapping("/{scheduleId}")
    @Operation(summary = "Cập nhật lịch học", description = "Không sửa được nếu lịch đã diễn ra và đã có điểm danh")
    public ResponseEntity<ScheduleDTO> updateSchedule(
            @PathVariable Integer scheduleId, @Valid @RequestBody UpdateScheduleRequest request) {
        return ResponseEntity.ok(staffScheduleService.updateSchedule(scheduleId, request));
    }

    @DeleteMapping("/{scheduleId}")
    @Operation(summary = "Xóa lịch học", description = "Không xóa được nếu lịch đã diễn ra và đã có điểm danh")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Integer scheduleId) {
        staffScheduleService.deleteSchedule(scheduleId);
        return ResponseEntity.noContent().build();
    }
}