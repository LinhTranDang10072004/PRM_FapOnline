package com.example.demo.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UpdateScheduleRequest {

    @NotNull(message = "Phòng học không được để trống")
    private Integer roomId;

    @NotNull(message = "Ca học không được để trống")
    private Integer timeSlotId;

    @NotNull(message = "Ngày học không được để trống")
    private LocalDate scheduleDate;

    @Size(max = 500, message = "Ghi chú không được vượt quá 500 ký tự")
    private String note;

   
    private String status;
}