package com.example.demo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LoginRequest {

	@NotBlank(message = "Username khong duoc de trong")
	private String username;

	@NotBlank(message = "Password khong duoc de trong")
	@Size(min = 6, message = "Password toi thieu 6 ky tu")
	private String password;
}
