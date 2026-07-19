package com.example.demo.controller;

import com.example.demo.dto.AdminRoleDTO;
import com.example.demo.dto.AdminRoleRequest;
import com.example.demo.dto.AdminUserDTO;
import com.example.demo.dto.AssignRoleRequest;
import com.example.demo.service.AdminRoleService;
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
 * UC: Manage Roles — Tạo role hoặc gán role cho user (Admin).
 */
@RestController
@RequestMapping("/api/admin/roles")
@RequiredArgsConstructor
@Tag(name = "Admin - Roles")
@PreAuthorize("hasRole('ADMIN')")
public class AdminRoleController {

    private final AdminRoleService adminRoleService;

    @GetMapping
    @Operation(summary = "Danh sách role")
    public ResponseEntity<List<AdminRoleDTO>> getRoles() {
        return ResponseEntity.ok(adminRoleService.getRoles());
    }

    @GetMapping("/{roleId}")
    @Operation(summary = "Chi tiết role")
    public ResponseEntity<AdminRoleDTO> getRole(@PathVariable Integer roleId) {
        return ResponseEntity.ok(adminRoleService.getRoleById(roleId));
    }

    @PostMapping
    @Operation(summary = "Tạo role mới")
    public ResponseEntity<AdminRoleDTO> createRole(@Valid @RequestBody AdminRoleRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminRoleService.createRole(request));
    }

    @PutMapping("/{roleId}")
    @Operation(summary = "Cập nhật role")
    public ResponseEntity<AdminRoleDTO> updateRole(
            @PathVariable Integer roleId,
            @Valid @RequestBody AdminRoleRequest request) {
        return ResponseEntity.ok(adminRoleService.updateRole(roleId, request));
    }

    @DeleteMapping("/{roleId}")
    @Operation(summary = "Xóa role (chỉ khi chưa gán cho user nào)")
    public ResponseEntity<Void> deleteRole(@PathVariable Integer roleId) {
        adminRoleService.deleteRole(roleId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/assign")
    @Operation(summary = "Gán role cho user")
    public ResponseEntity<AdminUserDTO> assignRole(@Valid @RequestBody AssignRoleRequest request) {
        return ResponseEntity.ok(adminRoleService.assignRole(request));
    }

    @PostMapping("/unassign")
    @Operation(summary = "Thu hồi role của user")
    public ResponseEntity<AdminUserDTO> unassignRole(@Valid @RequestBody AssignRoleRequest request) {
        return ResponseEntity.ok(adminRoleService.unassignRole(request));
    }
}
