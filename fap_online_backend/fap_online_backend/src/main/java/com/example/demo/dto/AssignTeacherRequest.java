package com.example.demo.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AssignTeacherRequest {

    @NotNull(message = "Giáo viên không được để trống")
    private Integer teacherId;
}