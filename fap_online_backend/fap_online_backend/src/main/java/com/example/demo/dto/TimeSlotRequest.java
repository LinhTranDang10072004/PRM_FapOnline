package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalTime;

@Data
public class TimeSlotRequest {

    @NotBlank(message = "Mã ca học không được để trống")
    @Size(max = 30, message = "Mã ca học không được vượt quá 30 ký tự")
    private String slotCode;

    @NotBlank(message = "Tên ca học không được để trống")
    @Size(max = 100, message = "Tên ca học không được vượt quá 100 ký tự")
    private String slotName;

    @NotNull(message = "Giờ bắt đầu không được để trống")
    private LocalTime startTime;

    @NotNull(message = "Giờ kết thúc không được để trống")
    private LocalTime endTime;

    /**
     * Optional. If omitted on create, defaults to "Active".
     * On update, null means "leave unchanged".
     */
    private String status;
}