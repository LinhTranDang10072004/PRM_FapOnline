package com.example.demo.controller;

import com.example.demo.dto.ChangePasswordRequest;
import com.example.demo.dto.ProfileDTO;
import com.example.demo.service.ParentProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;


@RestController
@RequestMapping("/api/parent/profile")
@RequiredArgsConstructor
@Tag(name = "Parent Profile APIs", description = "Endpoints for parents to view and update their profile")
@org.springframework.security.access.prepost.PreAuthorize("hasRole('PARENT')")
public class ParentProfileController {

    private final ParentProfileService parentProfileService;
    @GetMapping
    @Operation(summary = "Get Profile", description = "Retrieves the authenticated parent's profile details")
    public ResponseEntity<ProfileDTO> getProfile() {
        return ResponseEntity.ok(parentProfileService.getProfile());
    }

    @PutMapping
    @Operation(summary = "Update Profile", description = "Updates the authenticated parent's profile (Phone, Address, Avatar)")
    public ResponseEntity<Void> updateProfile(
            @Valid @RequestBody ProfileDTO profileDTO) {
        parentProfileService.updateProfile(profileDTO);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/change-password")
    @Operation(summary = "Change Password", description = "Changes the authenticated parent's password using BCrypt hashing")
    public ResponseEntity<Void> changePassword(
            @Valid @RequestBody ChangePasswordRequest request) {
        parentProfileService.changePassword(request);
        return ResponseEntity.noContent().build();
    }
}
