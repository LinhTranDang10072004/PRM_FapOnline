package com.example.demo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RoomRequest {

    @NotBlank(message = "Mã phòng không được để trống")
    @Size(max = 30, message = "Mã phòng không được vượt quá 30 ký tự")
    private String roomCode;

    @NotBlank(message = "Tên phòng không được để trống")
    @Size(max = 100, message = "Tên phòng không được vượt quá 100 ký tự")
    private String roomName;

    @NotNull(message = "Sức chứa không được để trống")
    @Min(value = 1, message = "Sức chứa phải lớn hơn 0")
    private Integer capacity;

    @Size(max = 150, message = "Vị trí không được vượt quá 150 ký tự")
    private String location;

    /**
     * Optional. If omitted on create, defaults to "Active".
     * On update, null means "leave unchanged".
     */
    private String status;
}