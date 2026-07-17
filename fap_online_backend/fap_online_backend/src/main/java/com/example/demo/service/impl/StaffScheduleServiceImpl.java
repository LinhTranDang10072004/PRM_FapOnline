package com.example.demo.service.impl;

import com.example.demo.dto.CreateScheduleRequest;
import com.example.demo.dto.ScheduleDTO;
import com.example.demo.dto.UpdateScheduleRequest;
import com.example.demo.entity.*;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.*;
import com.example.demo.service.StaffScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StaffScheduleServiceImpl implements StaffScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final SemesterRepository semesterRepository;
    private final ClassStudentRepository classStudentRepository;
    private final AttendanceRepository attendanceRepository;

    // ============================== READ ==============================

    @Override
    public List<ScheduleDTO> getSchedules(Integer classId, LocalDate date) {
        List<Schedule> schedules;
        if (classId != null && date != null) {
            schedules = scheduleRepository.findByClassId(classId).stream()
                    .filter(s -> s.getScheduleDate().equals(date))
                    .collect(Collectors.toList());
        } else if (classId != null) {
            schedules = scheduleRepository.findByClassId(classId);
        } else if (date != null) {
            schedules = scheduleRepository.findByScheduleDate(date);
        } else {
            schedules = scheduleRepository.findAll();
        }

        return schedules.stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    @Override
    public ScheduleDTO getScheduleById(Integer scheduleId) {
        return mapToDTO(getScheduleOrThrow(scheduleId));
    }

    // ============================== UC-16: Manage Schedule ==============================

    @Override
    public ScheduleDTO createSchedule(CreateScheduleRequest request) {
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp học"));

        assertClassNotLocked(schoolClass);

        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy phòng học"));
        if (!"Active".equalsIgnoreCase(room.getStatus())) {
            throw new ValidationException("Phòng học không ở trạng thái hoạt động");
        }

        TimeSlot timeSlot = timeSlotRepository.findById(request.getTimeSlotId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ca học"));
        if (!"Active".equalsIgnoreCase(timeSlot.getStatus())) {
            throw new ValidationException("Ca học không ở trạng thái hoạt động");
        }

        assertWithinSemester(schoolClass, request.getScheduleDate());

        validateNoConflicts(schoolClass, request.getRoomId(), request.getTimeSlotId(), request.getScheduleDate(), null);

        Schedule schedule = new Schedule();
        schedule.setClassId(schoolClass.getClassId());
        schedule.setRoomId(request.getRoomId());
        schedule.setTimeSlotId(request.getTimeSlotId());
        schedule.setScheduleDate(request.getScheduleDate());
        schedule.setNote(request.getNote());
        schedule.setStatus("Scheduled");
        schedule.setCreatedAt(LocalDateTime.now());

        return mapToDTO(scheduleRepository.save(schedule));
    }

    @Override
    public ScheduleDTO updateSchedule(Integer scheduleId, UpdateScheduleRequest request) {
        Schedule schedule = getScheduleOrThrow(scheduleId);
        assertNotPastWithAttendance(schedule, "sửa");

        SchoolClass schoolClass = schoolClassRepository.findById(schedule.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp học"));
        assertClassNotLocked(schoolClass);

        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy phòng học"));
        if (!"Active".equalsIgnoreCase(room.getStatus())) {
            throw new ValidationException("Phòng học không ở trạng thái hoạt động");
        }

        TimeSlot timeSlot = timeSlotRepository.findById(request.getTimeSlotId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ca học"));
        if (!"Active".equalsIgnoreCase(timeSlot.getStatus())) {
            throw new ValidationException("Ca học không ở trạng thái hoạt động");
        }

        assertWithinSemester(schoolClass, request.getScheduleDate());

        validateNoConflicts(schoolClass, request.getRoomId(), request.getTimeSlotId(), request.getScheduleDate(), scheduleId);

        schedule.setRoomId(request.getRoomId());
        schedule.setTimeSlotId(request.getTimeSlotId());
        schedule.setScheduleDate(request.getScheduleDate());
        schedule.setNote(request.getNote());
        if (request.getStatus() != null) {
            schedule.setStatus(request.getStatus());
        }
        schedule.setUpdatedAt(LocalDateTime.now());

        return mapToDTO(scheduleRepository.save(schedule));
    }

    @Override
    public void deleteSchedule(Integer scheduleId) {
        Schedule schedule = getScheduleOrThrow(scheduleId);
        assertNotPastWithAttendance(schedule, "xóa");
        scheduleRepository.delete(schedule);
    }

    // ============================== Helpers ==============================

    private Schedule getScheduleOrThrow(Integer scheduleId) {
        return scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch học"));
    }

    private void assertClassNotLocked(SchoolClass schoolClass) {
        String status = schoolClass.getStatus();
        if ("Completed".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)) {
            throw new ValidationException("Không thể tạo/sửa lịch cho lớp đã " + status);
        }
    }

    private void assertWithinSemester(SchoolClass schoolClass, LocalDate scheduleDate) {
        Semester semester = semesterRepository.findById(schoolClass.getSemesterId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học kỳ của lớp"));

        if (scheduleDate.isBefore(semester.getStartDate()) || scheduleDate.isAfter(semester.getEndDate())) {
            throw new ValidationException(
                    "Ngày học phải nằm trong khoảng thời gian của học kỳ (" +
                            semester.getStartDate() + " - " + semester.getEndDate() + ")");
        }
    }

    private void assertNotPastWithAttendance(Schedule schedule, String action) {
        boolean hasEnded;
        TimeSlot timeSlot = timeSlotRepository.findById(schedule.getTimeSlotId()).orElse(null);
        if (timeSlot != null) {
            // Compare against the exact moment the session ends (date + end time),
            // not just the date, so a same-day session that has already finished
            // is correctly treated as "đã diễn ra".
            LocalDateTime sessionEnd = LocalDateTime.of(schedule.getScheduleDate(), timeSlot.getEndTime());
            hasEnded = sessionEnd.isBefore(LocalDateTime.now());
        } else {
            hasEnded = schedule.getScheduleDate().isBefore(LocalDate.now());
        }

        if (hasEnded && attendanceRepository.existsByScheduleId(schedule.getScheduleId())) {
            throw new ValidationException(
                    "Không thể " + action + " lịch học đã diễn ra và đã có điểm danh (trừ khi có quyền đặc biệt)");
        }
    }

    /**
     * Enforces the three UC-16 conflict rules: room, teacher, student.
     * excludeScheduleId is non-null only on update, so the schedule being
     * edited never triggers a false-positive conflict with itself.
     */
    private void validateNoConflicts(SchoolClass schoolClass, Integer roomId, Integer timeSlotId,
                                     LocalDate scheduleDate, Integer excludeScheduleId) {

        // 0) Same class cannot have two sessions at the same date+timeSlot.
        //    This closes a gap the other three checks don't cover: if the class
        //    has no teacher assigned yet, the teacher-conflict check is skipped,
        //    and the student-conflict check deliberately excludes the class's
        //    own sessions — so without this, staff could double-book the same
        //    class into two rooms at the same time.
        List<Schedule> selfConflicts = scheduleRepository.findByClassId(schoolClass.getClassId())
                .stream()
                .filter(s -> s.getScheduleDate().equals(scheduleDate) && s.getTimeSlotId().equals(timeSlotId))
                .filter(s -> excludeScheduleId == null || !s.getScheduleId().equals(excludeScheduleId))
                .collect(Collectors.toList());
        if (!selfConflicts.isEmpty()) {
            throw new ValidationException("Lớp học này đã có lịch vào đúng ngày và ca học này rồi");
        }

        // 1) Room conflict
        List<Schedule> roomConflicts = scheduleRepository
                .findByRoomIdAndScheduleDateAndTimeSlotId(roomId, scheduleDate, timeSlotId)
                .stream()
                .filter(s -> excludeScheduleId == null || !s.getScheduleId().equals(excludeScheduleId))
                .collect(Collectors.toList());
        if (!roomConflicts.isEmpty()) {
            throw new ValidationException("Phòng học đã được sử dụng bởi lớp khác vào cùng thời gian này");
        }

        // 2) Teacher conflict
        if (schoolClass.getMainTeacherId() != null) {
            List<Integer> teacherClassIds = schoolClassRepository.findByMainTeacherId(schoolClass.getMainTeacherId())
                    .stream().map(SchoolClass::getClassId).collect(Collectors.toList());
            List<Schedule> teacherConflicts = teacherClassIds.isEmpty()
                    ? Collections.emptyList()
                    : scheduleRepository.findByClassIdInAndScheduleDateAndTimeSlotId(teacherClassIds, scheduleDate, timeSlotId)
                    .stream()
                    .filter(s -> excludeScheduleId == null || !s.getScheduleId().equals(excludeScheduleId))
                    .collect(Collectors.toList());
            if (!teacherConflicts.isEmpty()) {
                throw new ValidationException("Giáo viên của lớp đã có lịch dạy lớp khác vào cùng thời gian này");
            }
        }

        // 3) Student conflict
        List<Integer> studentIds = classStudentRepository.findByClassId(schoolClass.getClassId())
                .stream().map(ClassStudent::getStudentId).collect(Collectors.toList());
        if (!studentIds.isEmpty()) {
            List<Integer> studentOtherClassIds = studentIds.stream()
                    .flatMap(sid -> classStudentRepository.findByStudentId(sid).stream())
                    .map(ClassStudent::getClassId)
                    .filter(cid -> !cid.equals(schoolClass.getClassId()))
                    .distinct()
                    .collect(Collectors.toList());

            List<Schedule> studentConflicts = studentOtherClassIds.isEmpty()
                    ? Collections.emptyList()
                    : scheduleRepository.findByClassIdInAndScheduleDateAndTimeSlotId(studentOtherClassIds, scheduleDate, timeSlotId)
                    .stream()
                    .filter(s -> excludeScheduleId == null || !s.getScheduleId().equals(excludeScheduleId))
                    .collect(Collectors.toList());
            if (!studentConflicts.isEmpty()) {
                throw new ValidationException("Có sinh viên trong lớp bị trùng lịch học với lớp khác vào cùng thời gian này");
            }
        }
    }

    private ScheduleDTO mapToDTO(Schedule schedule) {
        SchoolClass schoolClass = schoolClassRepository.findById(schedule.getClassId()).orElse(null);
        Room room = roomRepository.findById(schedule.getRoomId()).orElse(null);
        TimeSlot timeSlot = timeSlotRepository.findById(schedule.getTimeSlotId()).orElse(null);

        return ScheduleDTO.builder()
                .scheduleId(schedule.getScheduleId())
                .classId(schedule.getClassId())
                .classCode(schoolClass != null ? schoolClass.getClassCode() : "")
                .className(schoolClass != null ? schoolClass.getClassName() : "")
                .roomId(schedule.getRoomId())
                .roomName(room != null ? room.getRoomName() : "")
                .timeSlotId(schedule.getTimeSlotId())
                .slotName(timeSlot != null ? timeSlot.getSlotName() : "")
                .startTime(timeSlot != null ? timeSlot.getStartTime() : null)
                .endTime(timeSlot != null ? timeSlot.getEndTime() : null)
                .scheduleDate(schedule.getScheduleDate())
                .note(schedule.getNote())
                .status(schedule.getStatus())
                .build();
    }
}