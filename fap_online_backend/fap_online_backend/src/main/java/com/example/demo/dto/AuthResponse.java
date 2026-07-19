package com.example.demo.dto;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthResponse {
    private Integer userId;
    private String token;
    private String username;
    private String fullName;
    private String role;
    private String message;
}
