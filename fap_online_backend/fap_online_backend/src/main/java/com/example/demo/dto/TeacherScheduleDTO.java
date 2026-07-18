package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TeacherScheduleDTO {


    private Integer scheduleId;


    private Integer classId;


    private String classCode;


    private String className;


    private String subjectName;


    private String roomName;


    private String scheduleDate;


    private String startTime;


    private String endTime;


    private String status;

}