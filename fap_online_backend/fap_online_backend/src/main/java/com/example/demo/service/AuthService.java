package com.example.demo.service;

import com.example.demo.dto.AuthResponse;
import com.example.demo.dto.LoginRequest;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.security.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;

	public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
		this.userRepository = userRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtService = jwtService;
	}

	public AuthResponse login(LoginRequest request) {
		User user = userRepository.findByUsername(request.getUsername())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sai username hoac password"));

		if (!"Active".equalsIgnoreCase(user.getStatus())) {
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Tai khoan khong hoat dong");
		}

		if (!checkPassword(request.getPassword(), user.getPasswordHash())) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sai username hoac password");
		}

		String token = jwtService.generateToken(user.getUserId(), user.getUsername(), user.getFullName());
		return new AuthResponse(token, user.getUsername(), user.getFullName(), "Dang nhap thanh cong");
	}

	public AuthResponse me(String token) {
		JwtService.TokenData tokenData = validateToken(token);
		return new AuthResponse(extractToken(token), tokenData.getUsername(), tokenData.getFullName(), "Token hop le");
	}

	public AuthResponse logout() {
		return new AuthResponse(null, null, null, "Dang xuat thanh cong");
	}

	public JwtService.TokenData validateToken(String authorizationHeader) {
		JwtService.TokenData tokenData = jwtService.parseToken(extractToken(authorizationHeader));
		if (tokenData == null) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Token khong hop le hoac da het han");
		}
		return tokenData;
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
