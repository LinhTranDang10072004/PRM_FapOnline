package com.example.demo.service;

import com.example.demo.dto.AuthResponse;
import com.example.demo.dto.LoginRequest;
import com.example.demo.entity.Role;
import com.example.demo.entity.User;
import com.example.demo.entity.UserRole;
import com.example.demo.repository.RoleRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.UserRoleRepository;
import com.example.demo.security.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AuthService {

	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;
	private final UserRoleRepository userRoleRepository;
	private final RoleRepository roleRepository;

	public AuthService(
			UserRepository userRepository,
			PasswordEncoder passwordEncoder,
			JwtService jwtService,
			UserRoleRepository userRoleRepository,
			RoleRepository roleRepository) {
		this.userRepository = userRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtService = jwtService;
		this.userRoleRepository = userRoleRepository;
		this.roleRepository = roleRepository;
	}

	public AuthResponse login(LoginRequest request) {
		User user = userRepository.findByUsernameOrEmail(request.getUsername(), request.getUsername())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sai username hoac password"));

		if (!"Active".equalsIgnoreCase(user.getStatus())) {
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Tai khoan khong hoat dong");
		}

		if (!checkPassword(request.getPassword(), user.getPasswordHash())) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sai username hoac password");
		}

		String token = jwtService.generateToken(user.getUserId(), user.getUsername(), user.getFullName());
		String role = resolvePrimaryRole(user.getUserId());
		return new AuthResponse(
				user.getUserId(),
				token,
				user.getUsername(),
				user.getFullName(),
				role,
				"Dang nhap thanh cong");
	}

	public AuthResponse me(String token) {
		JwtService.TokenData tokenData = validateToken(token);
		String role = resolvePrimaryRole(tokenData.getUserId());
		return new AuthResponse(
				tokenData.getUserId(),
				extractToken(token),
				tokenData.getUsername(),
				tokenData.getFullName(),
				role,
				"Token hop le");
	}

	public AuthResponse logout() {
		return new AuthResponse(null, null, null, null, null, "Dang xuat thanh cong");
	}

	public JwtService.TokenData validateToken(String authorizationHeader) {
		JwtService.TokenData tokenData = jwtService.parseToken(extractToken(authorizationHeader));
		if (tokenData == null) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Token khong hop le hoac da het han");
		}
		return tokenData;
	}

	public String resolvePrimaryRole(Integer userId) {
		if (userId == null) {
			return null;
		}

		List<UserRole> userRoles = userRoleRepository.findByUserId(userId);
		if (userRoles.isEmpty()) {
			return null;
		}

		List<Integer> roleIds = userRoles.stream()
				.map(UserRole::getRoleId)
				.distinct()
				.collect(Collectors.toList());

		Map<Integer, Role> roleMap = roleRepository.findAllById(roleIds).stream()
				.collect(Collectors.toMap(Role::getRoleId, r -> r));

		return roleIds.stream()
				.map(roleMap::get)
				.filter(role -> role != null && Boolean.TRUE.equals(role.getIsActive()))
				.map(Role::getRoleName)
				.map(this::normalizeRole)
				.findFirst()
				.orElse(null);
	}

	private String normalizeRole(String roleName) {
		if (roleName == null || roleName.isBlank()) {
			return null;
		}
		String normalized = roleName.trim().toUpperCase();
		if (normalized.startsWith("ROLE_")) {
			normalized = normalized.substring(5);
		}
		return normalized;
	}

	private boolean checkPassword(String rawPassword, String storedPassword) {
		try {
			if (passwordEncoder.matches(rawPassword, storedPassword)) {
				return true;
			}
		} catch (IllegalArgumentException ex) {
			// Bo qua hash khong hop le trong DB demo
		}
		return storedPassword != null && storedPassword.equals(rawPassword);
	}

	private String extractToken(String authorizationHeader) {
		if (authorizationHeader == null || authorizationHeader.isBlank()) {
			return null;
		}
		if (authorizationHeader.startsWith("Bearer ")) {
			return authorizationHeader.substring(7).trim();
		}
		return authorizationHeader.trim();
	}
}
