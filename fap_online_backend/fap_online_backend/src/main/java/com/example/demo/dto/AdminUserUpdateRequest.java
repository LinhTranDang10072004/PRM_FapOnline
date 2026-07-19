package com.example.demo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminUserUpdateRequest {

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

    /** Optional. Để trống = không đổi mật khẩu. */
    @Size(min = 6, max = 100, message = "Password phải từ 6-100 ký tự")
    private String password;

    /** Optional. Đổi role chính nếu có. */
    private String roleName;
}
