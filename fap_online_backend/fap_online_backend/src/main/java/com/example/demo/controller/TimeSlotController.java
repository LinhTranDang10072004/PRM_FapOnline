package com.example.demo.controller;

import com.example.demo.dto.TimeSlotDTO;
import com.example.demo.dto.TimeSlotRequest;
import com.example.demo.service.TimeSlotService;
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
@RequestMapping("/api/staff/timeslots")
@RequiredArgsConstructor
@Tag(name = "Staff - Time Slots", description = "UC-17: Quản lý ca học")
@PreAuthorize("hasRole('STAFF')")
public class TimeSlotController {

    private final TimeSlotService timeSlotService;

    @GetMapping
    @Operation(summary = "Danh sách ca học")
    public ResponseEntity<List<TimeSlotDTO>> getAllTimeSlots() {
        return ResponseEntity.ok(timeSlotService.getAllTimeSlots());
    }

    @GetMapping("/{timeSlotId}")
    @Operation(summary = "Chi tiết ca học")
    public ResponseEntity<TimeSlotDTO> getTimeSlotById(
            @Parameter(description = "ID của ca học") @PathVariable Integer timeSlotId) {
        return ResponseEntity.ok(timeSlotService.getTimeSlotById(timeSlotId));
    }

    @PostMapping
    @Operation(summary = "Tạo ca học mới")
    public ResponseEntity<TimeSlotDTO> createTimeSlot(@Valid @RequestBody TimeSlotRequest request) {
        return ResponseEntity.ok(timeSlotService.createTimeSlot(request));
    }

    @PutMapping("/{timeSlotId}")
    @Operation(summary = "Cập nhật ca học")
    public ResponseEntity<TimeSlotDTO> updateTimeSlot(
            @Parameter(description = "ID của ca học") @PathVariable Integer timeSlotId,
            @Valid @RequestBody TimeSlotRequest request) {
        return ResponseEntity.ok(timeSlotService.updateTimeSlot(timeSlotId, request));
    }

    @DeleteMapping("/{timeSlotId}")
    @Operation(summary = "Xóa ca học", description = "Chỉ xóa được nếu ca học chưa được dùng trong bất kỳ lịch học nào")
    public ResponseEntity<Void> deleteTimeSlot(
            @Parameter(description = "ID của ca học") @PathVariable Integer timeSlotId) {
        timeSlotService.deleteTimeSlot(timeSlotId);
        return ResponseEntity.noContent().build();
    }
}