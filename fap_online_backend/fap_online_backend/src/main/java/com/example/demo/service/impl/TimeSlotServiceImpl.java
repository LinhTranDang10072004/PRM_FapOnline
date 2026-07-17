package com.example.demo.service.impl;

import com.example.demo.dto.TimeSlotDTO;
import com.example.demo.dto.TimeSlotRequest;
import com.example.demo.entity.TimeSlot;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.ScheduleRepository;
import com.example.demo.repository.TimeSlotRepository;
import com.example.demo.service.TimeSlotService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TimeSlotServiceImpl implements TimeSlotService {

    private final TimeSlotRepository timeSlotRepository;
    private final ScheduleRepository scheduleRepository;

    @Override
    public List<TimeSlotDTO> getAllTimeSlots() {
        return timeSlotRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public TimeSlotDTO getTimeSlotById(Integer timeSlotId) {
        TimeSlot timeSlot = timeSlotRepository.findById(timeSlotId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ca học"));
        return mapToDTO(timeSlot);
    }

    @Override
    public TimeSlotDTO createTimeSlot(TimeSlotRequest request) {
        validateTimeRange(request);

        String slotCode = request.getSlotCode().trim();
        if (timeSlotRepository.existsBySlotCode(slotCode)) {
            throw new ValidationException("Mã ca học đã tồn tại");
        }

        validateNoOverlap(request, null);

        TimeSlot timeSlot = new TimeSlot();
        timeSlot.setSlotCode(slotCode);
        timeSlot.setSlotName(request.getSlotName());
        timeSlot.setStartTime(request.getStartTime());
        timeSlot.setEndTime(request.getEndTime());
        timeSlot.setStatus(request.getStatus() != null ? request.getStatus() : "Active");

        return mapToDTO(timeSlotRepository.save(timeSlot));
    }

    @Override
    public TimeSlotDTO updateTimeSlot(Integer timeSlotId, TimeSlotRequest request) {
        TimeSlot timeSlot = timeSlotRepository.findById(timeSlotId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ca học"));

        validateTimeRange(request);

        String slotCode = request.getSlotCode().trim();
        if (timeSlotRepository.existsBySlotCodeAndTimeSlotIdNot(slotCode, timeSlotId)) {
            throw new ValidationException("Mã ca học đã tồn tại");
        }

        validateNoOverlap(request, timeSlotId);

        timeSlot.setSlotCode(slotCode);
        timeSlot.setSlotName(request.getSlotName());
        timeSlot.setStartTime(request.getStartTime());
        timeSlot.setEndTime(request.getEndTime());
        if (request.getStatus() != null) {
            timeSlot.setStatus(request.getStatus());
        }

        return mapToDTO(timeSlotRepository.save(timeSlot));
    }

    @Override
    public void deleteTimeSlot(Integer timeSlotId) {
        TimeSlot timeSlot = timeSlotRepository.findById(timeSlotId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ca học"));

        if (scheduleRepository.existsByTimeSlotId(timeSlotId)) {
            throw new ValidationException(
                    "Ca học đang được sử dụng trong lịch học, không thể xóa cứng. " +
                            "Hãy cập nhật trạng thái ca học sang Inactive thay vì xóa.");
        }

        timeSlotRepository.delete(timeSlot);
    }

    private void validateTimeRange(TimeSlotRequest request) {
        if (!request.getStartTime().isBefore(request.getEndTime())) {
            throw new ValidationException("Giờ bắt đầu phải nhỏ hơn giờ kết thúc");
        }
    }

    /**
     * Business rule: time slots active on the same day must not overlap.
     * TimeSlot is a shared/global slot definition reused across days, so the
     * check compares against every other currently-Active slot, excluding
     * the record being updated (if any) and Inactive slots (retired, no longer scheduled).
     */
    private void validateNoOverlap(TimeSlotRequest request, Integer excludeId) {
        boolean overlap = timeSlotRepository.findAll().stream()
                .filter(ts -> excludeId == null || !ts.getTimeSlotId().equals(excludeId))
                .filter(ts -> !"Inactive".equalsIgnoreCase(ts.getStatus()))
                .anyMatch(ts -> request.getStartTime().isBefore(ts.getEndTime())
                        && ts.getStartTime().isBefore(request.getEndTime()));

        if (overlap) {
            throw new ValidationException("Ca học bị trùng thời gian với một ca học khác đang hoạt động");
        }
    }

    private TimeSlotDTO mapToDTO(TimeSlot timeSlot) {
        return TimeSlotDTO.builder()
                .timeSlotId(timeSlot.getTimeSlotId())
                .slotCode(timeSlot.getSlotCode())
                .slotName(timeSlot.getSlotName())
                .startTime(timeSlot.getStartTime())
                .endTime(timeSlot.getEndTime())
                .status(timeSlot.getStatus())
                .build();
    }
}