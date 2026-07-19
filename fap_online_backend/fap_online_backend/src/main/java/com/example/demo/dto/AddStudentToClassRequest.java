package com.example.demo.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddStudentToClassRequest {

    @NotNull(message = "Sinh viên không được để trống")
    private Integer studentId;
}