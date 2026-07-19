package com.example.demo.controller;

import com.example.demo.dto.StudentApplicationDto;
import com.example.demo.security.AuthenticatedUser;
import com.example.demo.service.StudentApplicationService;
import com.example.demo.validation.ApplicationSubmitRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/applications")
public class ApplicationController {

	private final StudentApplicationService studentApplicationService;

	public ApplicationController(StudentApplicationService studentApplicationService) {
		this.studentApplicationService = studentApplicationService;
	}

	@GetMapping("/my")
	public ResponseEntity<List<StudentApplicationDto>> getMyApplications(
			@AuthenticationPrincipal AuthenticatedUser user) {
		return ResponseEntity.ok(studentApplicationService.getMyApplications(user.getUserId()));
	}

	@PostMapping
	public ResponseEntity<?> submitApplication(
			@AuthenticationPrincipal AuthenticatedUser user,
			@Valid @RequestBody ApplicationSubmitRequest request) {
		boolean success = studentApplicationService.submitApplication(user.getUserId(), request);
		return success
				? ResponseEntity.ok("Application submitted")
				: ResponseEntity.badRequest().body("Failed to submit");
	}
}
