package com.example.demo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateClassRequest {

    @NotBlank(message = "Mã lớp không được để trống")
    @Size(max = 30, message = "Mã lớp không được vượt quá 30 ký tự")
    private String classCode;

    @NotBlank(message = "Tên lớp không được để trống")
    @Size(max = 150, message = "Tên lớp không được vượt quá 150 ký tự")
    private String className;

    @NotNull(message = "Sĩ số tối đa không được để trống")
    @Min(value = 1, message = "Sĩ số tối đa phải lớn hơn 0")
    private Integer maxStudents;

    /**
     * Optional. Must be one of: Draft, Open, In Progress, Completed, Cancelled.
     * Null means "leave unchanged". Note: Subject and Semester cannot be changed
     * after creation — changing them would silently orphan existing schedules,
     * grades and enrollments tied to the original subject/semester.
     */
    private String status;
}