package com.example.demo.controller;

import com.example.demo.dto.DashboardResponse;
import com.example.demo.service.ParentDashboardService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/parent/dashboard")
@RequiredArgsConstructor
@Tag(name = "Parent Dashboard", description = "Endpoints for the parent dashboard overview")
@PreAuthorize("hasRole('PARENT')")
public class ParentDashboardController {

    private final ParentDashboardService parentDashboardService;

    @GetMapping
    public ResponseEntity<DashboardResponse> getDashboard() {
        return ResponseEntity.ok(parentDashboardService.getDashboardData());
    }
}
