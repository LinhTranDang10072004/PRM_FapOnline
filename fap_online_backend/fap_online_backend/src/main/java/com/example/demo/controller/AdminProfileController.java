package com.example.demo.controller;

import com.example.demo.dto.AdminProfileDTO;
import com.example.demo.dto.AdminProfileUpdateRequest;
import com.example.demo.dto.ChangePasswordRequest;
import com.example.demo.service.AdminProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * UC: View / Update Profile (Admin).
 * Đổi password: nhập mật khẩu cũ + mới (không gửi email).
 */
@RestController
@RequestMapping("/api/admin/profile")
@RequiredArgsConstructor
@Tag(name = "Admin - Profile")
@PreAuthorize("hasRole('ADMIN')")
public class AdminProfileController {

    private final AdminProfileService adminProfileService;

    @GetMapping
    @Operation(summary = "Xem thông tin cá nhân")
    public ResponseEntity<AdminProfileDTO> getProfile() {
        return ResponseEntity.ok(adminProfileService.getProfile());
    }

    @PutMapping
    @Operation(summary = "Cập nhật thông tin cá nhân")
    public ResponseEntity<AdminProfileDTO> updateProfile(
            @Valid @RequestBody AdminProfileUpdateRequest request) {
        return ResponseEntity.ok(adminProfileService.updateProfile(request));
    }

    @PutMapping("/change-password")
    @Operation(summary = "Đổi mật khẩu (cần mật khẩu cũ, không gửi email)")
    public ResponseEntity<Void> changePassword(
            @Valid @RequestBody ChangePasswordRequest request) {
        adminProfileService.changePassword(request);
        return ResponseEntity.noContent().build();
    }
}
