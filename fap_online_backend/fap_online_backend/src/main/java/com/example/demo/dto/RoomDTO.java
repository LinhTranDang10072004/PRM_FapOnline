package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoomDTO {
    private Integer roomId;
    private String roomCode;
    private String roomName;
    private Integer capacity;
    private String location;
    private String status;
}