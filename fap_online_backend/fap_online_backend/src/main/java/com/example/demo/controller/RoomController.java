package com.example.demo.controller;

import com.example.demo.dto.RoomDTO;
import com.example.demo.dto.RoomRequest;
import com.example.demo.service.RoomService;
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
@RequestMapping("/api/staff/rooms")
@RequiredArgsConstructor
@Tag(name = "Staff - Rooms", description = "UC-17: Quản lý phòng học")
@PreAuthorize("hasAnyRole('STAFF','ADMIN')")
public class RoomController {

    private final RoomService roomService;

    @GetMapping
    @Operation(summary = "Danh sách phòng học")
    public ResponseEntity<List<RoomDTO>> getAllRooms() {
        return ResponseEntity.ok(roomService.getAllRooms());
    }

    @GetMapping("/{roomId}")
    @Operation(summary = "Chi tiết phòng học")
    public ResponseEntity<RoomDTO> getRoomById(
            @Parameter(description = "ID của phòng học") @PathVariable Integer roomId) {
        return ResponseEntity.ok(roomService.getRoomById(roomId));
    }

    @PostMapping
    @Operation(summary = "Tạo phòng học mới")
    public ResponseEntity<RoomDTO> createRoom(@Valid @RequestBody RoomRequest request) {
        return ResponseEntity.ok(roomService.createRoom(request));
    }

    @PutMapping("/{roomId}")
    @Operation(summary = "Cập nhật phòng học")
    public ResponseEntity<RoomDTO> updateRoom(
            @Parameter(description = "ID của phòng học") @PathVariable Integer roomId,
            @Valid @RequestBody RoomRequest request) {
        return ResponseEntity.ok(roomService.updateRoom(roomId, request));
    }

    @DeleteMapping("/{roomId}")
    @Operation(summary = "Xóa phòng học", description = "Chỉ xóa được nếu phòng chưa được dùng trong bất kỳ lịch học nào")
    public ResponseEntity<Void> deleteRoom(
            @Parameter(description = "ID của phòng học") @PathVariable Integer roomId) {
        roomService.deleteRoom(roomId);
        return ResponseEntity.noContent().build();
    }
}