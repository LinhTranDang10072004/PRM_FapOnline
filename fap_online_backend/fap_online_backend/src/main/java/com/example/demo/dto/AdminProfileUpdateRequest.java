package com.example.demo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminProfileUpdateRequest {

    @Size(max = 150)
    private String fullName;

    @Email(message = "Email không hợp lệ")
    @Size(max = 100)
    private String email;

    @Size(max = 20)
    private String phone;

    private String gender;

    @Size(max = 255)
    private String address;
}
