package com.example.demo.security;

public class AuthenticatedUser {

	private final Integer userId;
	private final String username;
	private final String fullName;

	public AuthenticatedUser(Integer userId, String username, String fullName) {
		this.userId = userId;
		this.username = username;
		this.fullName = fullName;
	}

	public Integer getUserId() {
		return userId;
	}

	public String getUsername() {
		return username;
	}

	public String getFullName() {
		return fullName;
	}
}
