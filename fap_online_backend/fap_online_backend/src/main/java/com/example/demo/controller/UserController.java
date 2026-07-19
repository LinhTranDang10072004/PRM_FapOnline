package com.example.demo.controller;

import com.example.demo.dto.StudentProfileDto;
import com.example.demo.security.AuthenticatedUser;
import com.example.demo.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

	private final UserService userService;

	public UserController(UserService userService) {
		this.userService = userService;
	}

	@GetMapping("/profile")
	public ResponseEntity<StudentProfileDto> getProfile(@AuthenticationPrincipal AuthenticatedUser user) {
		StudentProfileDto profile = userService.getProfile(user.getUsername());
		return profile != null ? ResponseEntity.ok(profile) : ResponseEntity.notFound().build();
	}

	@PutMapping("/profile")
	public ResponseEntity<?> updateProfile(
			@AuthenticationPrincipal AuthenticatedUser user,
			@RequestBody StudentProfileDto dto) {
		boolean success = userService.updateProfile(user.getUsername(), dto);
		return success
				? ResponseEntity.ok("Profile updated successfully")
				: ResponseEntity.badRequest().body("Failed to update profile");
	}
}
