package com.example.demo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateClassRequest {

    @NotBlank(message = "Mã lớp không được để trống")
    @Size(max = 30, message = "Mã lớp không được vượt quá 30 ký tự")
    private String classCode;

    @NotBlank(message = "Tên lớp không được để trống")
    @Size(max = 150, message = "Tên lớp không được vượt quá 150 ký tự")
    private String className;

    @NotNull(message = "Môn học không được để trống")
    private Integer subjectId;

    @NotNull(message = "Học kỳ không được để trống")
    private Integer semesterId;

    @NotNull(message = "Sĩ số tối đa không được để trống")
    @Min(value = 1, message = "Sĩ số tối đa phải lớn hơn 0")
    private Integer maxStudents;

    /**
     * Optional. Must be one of: Draft, Open, In Progress, Completed, Cancelled.
     * Defaults to "Draft" if omitted.
     */
    private String status;
}