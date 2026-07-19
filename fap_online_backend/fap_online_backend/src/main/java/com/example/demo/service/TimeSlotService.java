package com.example.demo.service;

import com.example.demo.dto.TimeSlotDTO;
import com.example.demo.dto.TimeSlotRequest;

import java.util.List;

public interface TimeSlotService {
    List<TimeSlotDTO> getAllTimeSlots();

    TimeSlotDTO getTimeSlotById(Integer timeSlotId);

    TimeSlotDTO createTimeSlot(TimeSlotRequest request);

    TimeSlotDTO updateTimeSlot(Integer timeSlotId, TimeSlotRequest request);

    void deleteTimeSlot(Integer timeSlotId);
}