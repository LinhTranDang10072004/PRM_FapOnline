package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleDTO {
    private Integer scheduleId;
    private Integer classId;
    private String classCode;
    private String className;
    private Integer roomId;
    private String roomName;
    private Integer timeSlotId;
    private String slotName;
    private LocalTime startTime;
    private LocalTime endTime;
    private LocalDate scheduleDate;
    private String note;
    private String status;
}