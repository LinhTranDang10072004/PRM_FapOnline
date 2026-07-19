package com.example.demo.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AdminRoleDTO {

    private Integer roleId;
    private String roleName;
    private String description;
    private Boolean isActive;
    private long userCount;
    private LocalDateTime createdAt;
}
