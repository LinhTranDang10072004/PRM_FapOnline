package com.example.demo.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AssignRoleRequest {

    @NotNull(message = "userId không được để trống")
    private Integer userId;

    @NotNull(message = "roleId không được để trống")
    private Integer roleId;
}
