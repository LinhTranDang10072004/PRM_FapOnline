package com.example.demo.controller;

import com.example.demo.dto.AdminUserCreateRequest;
import com.example.demo.dto.AdminUserDTO;
import com.example.demo.dto.AdminUserUpdateRequest;
import com.example.demo.service.AdminUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UC: Manage Users — Thêm, sửa, xóa, khóa/mở khóa tài khoản (Admin).
 */
@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
@Tag(name = "Admin - Users")
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final AdminUserService adminUserService;

    @GetMapping
    @Operation(summary = "Danh sách người dùng")
    public ResponseEntity<List<AdminUserDTO>> getUsers(
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String q) {
        return ResponseEntity.ok(adminUserService.getUsers(role, status, q));
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Chi tiết người dùng")
    public ResponseEntity<AdminUserDTO> getUser(@PathVariable Integer userId) {
        return ResponseEntity.ok(adminUserService.getUserById(userId));
    }

    @PostMapping
    @Operation(summary = "Tạo tài khoản mới")
    public ResponseEntity<AdminUserDTO> createUser(@Valid @RequestBody AdminUserCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminUserService.createUser(request));
    }

    @PutMapping("/{userId}")
    @Operation(summary = "Cập nhật tài khoản")
    public ResponseEntity<AdminUserDTO> updateUser(
            @PathVariable Integer userId,
            @Valid @RequestBody AdminUserUpdateRequest request) {
        return ResponseEntity.ok(adminUserService.updateUser(userId, request));
    }

    @DeleteMapping("/{userId}")
    @Operation(summary = "Xóa tài khoản (soft delete)")
    public ResponseEntity<Void> deleteUser(@PathVariable Integer userId) {
        adminUserService.deleteUser(userId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{userId}/lock")
    @Operation(summary = "Khóa tài khoản")
    public ResponseEntity<AdminUserDTO> lockUser(@PathVariable Integer userId) {
        return ResponseEntity.ok(adminUserService.lockUser(userId));
    }

    @PutMapping("/{userId}/unlock")
    @Operation(summary = "Mở khóa tài khoản")
    public ResponseEntity<AdminUserDTO> unlockUser(@PathVariable Integer userId) {
        return ResponseEntity.ok(adminUserService.unlockUser(userId));
    }
}
