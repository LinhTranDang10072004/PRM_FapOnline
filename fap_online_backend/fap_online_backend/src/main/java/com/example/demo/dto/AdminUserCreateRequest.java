package com.example.demo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminUserCreateRequest {

    @NotBlank(message = "Username không được để trống")
    @Size(max = 50)
    private String username;

    @NotBlank(message = "Password không được để trống")
    @Size(min = 6, max = 100, message = "Password phải từ 6-100 ký tự")
    private String password;

    @NotBlank(message = "Họ tên không được để trống")
    @Size(max = 150)
    private String fullName;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    @Size(max = 100)
    private String email;

    @Size(max = 20)
    private String phone;

    private String gender;

    @Size(max = 255)
    private String address;

    /** ADMIN | STAFF | TEACHER | STUDENT | PARENT */
    @NotBlank(message = "Role không được để trống")
    private String roleName;

    /** Mã hồ sơ (studentCode / teacherCode / ...). Tự sinh nếu bỏ trống. */
    @Size(max = 30)
    private String profileCode;
}
