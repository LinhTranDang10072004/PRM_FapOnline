package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminRoleRequest {

    @NotBlank(message = "Tên role không được để trống")
    @Size(max = 50)
    private String roleName;

    @Size(max = 255)
    private String description;

    /** Optional. Default true khi tạo mới. */
    private Boolean isActive;
}
