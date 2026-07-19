package com.example.demo.dto;


import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TodayScheduleDTO {
    private Integer studentId;
    private String studentName;
    private String subjectCode;
    private String roomName;
    private String timeSlot;
}

