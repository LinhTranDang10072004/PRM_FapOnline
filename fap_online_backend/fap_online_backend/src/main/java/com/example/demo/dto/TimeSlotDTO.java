package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TimeSlotDTO {
    private Integer timeSlotId;
    private String slotCode;
    private String slotName;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status;
}
