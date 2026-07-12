package com.example.demo.controller;

import com.example.demo.util.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;


@RestController
@RequestMapping("/api/staff")
@Tag(name = "Staff", description = "Endpoints for Staff (Phòng đào tạo)")
@PreAuthorize("hasRole('STAFF')")
public class StaffController {

    @GetMapping("/ping")
    @Operation(summary = "Staff auth test", description = "Returns the authenticated user's id if JWT + STAFF role checks pass")
    public ResponseEntity<Map<String, Object>> ping() {
        Integer userId = SecurityUtils.extractUserId();
        return ResponseEntity.ok(Map.of(
                "message", "Xác thực và phân quyền STAFF hoạt động chính xác.",
                "userId", userId
        ));
    }
}