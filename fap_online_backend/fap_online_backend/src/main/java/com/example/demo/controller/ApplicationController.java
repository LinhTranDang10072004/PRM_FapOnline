package com.example.demo.controller;

import com.example.demo.dto.ApplicationDto;
import com.example.demo.security.AuthenticatedUser;
import com.example.demo.service.ApplicationService;
import com.example.demo.validation.ApplicationSubmitRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/applications")
public class ApplicationController {

	private final ApplicationService applicationService;

	public ApplicationController(ApplicationService applicationService) {
		this.applicationService = applicationService;
	}

	@GetMapping("/my")
	public ResponseEntity<List<ApplicationDto>> getMyApplications(@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(applicationService.getMyApplications(user.getUserId()));
	}

	@PostMapping
	public ResponseEntity<?> submitApplication(
			@AuthenticationPrincipal AuthenticatedUser user,
			@Valid @RequestBody ApplicationSubmitRequest request) {
		boolean success = applicationService.submitApplication(user.getUserId(), request);
		return success
				? ResponseEntity.ok("Application submitted")
				: ResponseEntity.badRequest().body("Failed to submit");
	}
}
