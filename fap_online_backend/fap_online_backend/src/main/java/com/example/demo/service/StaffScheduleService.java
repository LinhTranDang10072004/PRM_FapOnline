package com.example.demo.service;

import com.example.demo.dto.CreateScheduleRequest;
import com.example.demo.dto.ScheduleDTO;
import com.example.demo.dto.UpdateScheduleRequest;

import java.time.LocalDate;
import java.util.List;

public interface StaffScheduleService {

    List<ScheduleDTO> getSchedules(Integer classId, LocalDate date);

    ScheduleDTO getScheduleById(Integer scheduleId);

    ScheduleDTO createSchedule(CreateScheduleRequest request);

    ScheduleDTO updateSchedule(Integer scheduleId, UpdateScheduleRequest request);

    void deleteSchedule(Integer scheduleId);
}