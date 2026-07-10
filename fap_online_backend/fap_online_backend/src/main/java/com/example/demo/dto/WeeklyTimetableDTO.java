package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;
@Data @Builder public class WeeklyTimetableDTO {
    private LocalDate scheduleDate;
    private String subjectCode;
    private String roomName;
    private String timeSlot;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status;
}
