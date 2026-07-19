package com.example.demo.service.impl;

import com.example.demo.dto.ScheduleDTO;
import com.example.demo.dto.StaffDashboardDTO;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import com.example.demo.service.StaffDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * UC-12: View Staff Dashboard
 *
 * Aggregate dữ liệu từ nhiều bảng để trả về tổng quan cho Staff:
 *
 * Thông tin hiển thị (theo đặc tả):
 *  1. Số lượng lớp đang hoạt động (status ≠ Cancelled, Completed)
 *  2. Lịch học hôm nay (scheduleDate = TODAY)
 *  3. Số đơn đang chờ xử lý (status = Pending)
 *  4. Số lớp có giáo viên được phân công (mainTeacherId IS NOT NULL)
 *  5. Tổng số sinh viên distinct đang tham gia lớp
 *
 * Business Rule:
 *  BR-10: Dữ liệu dashboard chỉ hiển thị cho Staff đã đăng nhập.
 *         (Enforce tại Controller bằng @PreAuthorize("hasRole('STAFF')"))
 */
@Service
@RequiredArgsConstructor
public class StaffDashboardServiceImpl implements StaffDashboardService {

    private final SchoolClassRepository schoolClassRepository;
    private final ApplicationRepository applicationRepository;
    private final ScheduleRepository scheduleRepository;
    private final ClassStudentRepository classStudentRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;

    private static final List<String> INACTIVE_CLASS_STATUSES = List.of("Cancelled", "Completed");

    @Override
    public StaffDashboardDTO getDashboard() {

        // ── 1. Số lớp đang hoạt động (status ≠ Cancelled, Completed) ──
        long totalActiveClasses = schoolClassRepository.countByStatusNotIn(INACTIVE_CLASS_STATUSES);

        // ── 2. Số đơn chờ xử lý ──
        long totalPendingApplications = applicationRepository.findByStatus("Pending").size();

        // ── 3. Số lớp có giáo viên được phân công ──
        long totalAssignedTeachers = schoolClassRepository.countByMainTeacherIdIsNotNull();

        // ── 4. Tổng sinh viên distinct đang tham gia ít nhất một lớp ──
        long totalEnrolledStudents = classStudentRepository.findAll()
                .stream()
                .map(ClassStudent::getStudentId)
                .distinct()
                .count();

        // ── 5. Lịch học hôm nay ──
        LocalDate today = LocalDate.now();
        List<Schedule> todayRaw = scheduleRepository.findByScheduleDate(today);
        List<ScheduleDTO> todaySchedules = mapSchedules(todayRaw);

        return StaffDashboardDTO.builder()
                .totalActiveClasses(totalActiveClasses)
                .totalPendingApplications(totalPendingApplications)
                .totalAssignedTeachers(totalAssignedTeachers)
                .totalEnrolledStudents(totalEnrolledStudents)
                .todaySchedules(todaySchedules)
                .build();
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    /**
     * Map danh sách Schedule entity → ScheduleDTO.
     * Batch-load Room và TimeSlot để tránh N+1.
     */
    private List<ScheduleDTO> mapSchedules(List<Schedule> schedules) {
        if (schedules.isEmpty()) return List.of();

        // Batch-load Class
        List<Integer> classIds = schedules.stream()
                .map(Schedule::getClassId).distinct().collect(Collectors.toList());
        Map<Integer, SchoolClass> classMap = schoolClassRepository.findAllById(classIds)
                .stream().collect(Collectors.toMap(SchoolClass::getClassId, c -> c));

        // Batch-load Room
        List<Integer> roomIds = schedules.stream()
                .map(Schedule::getRoomId).distinct().collect(Collectors.toList());
        Map<Integer, Room> roomMap = roomRepository.findAllById(roomIds)
                .stream().collect(Collectors.toMap(Room::getRoomId, r -> r));

        // Batch-load TimeSlot
        List<Integer> slotIds = schedules.stream()
                .map(Schedule::getTimeSlotId).distinct().collect(Collectors.toList());
        Map<Integer, TimeSlot> slotMap = timeSlotRepository.findAllById(slotIds)
                .stream().collect(Collectors.toMap(TimeSlot::getTimeSlotId, s -> s));

        return schedules.stream().map(s -> {
            SchoolClass sc = classMap.get(s.getClassId());
            Room room     = roomMap.get(s.getRoomId());
            TimeSlot slot = slotMap.get(s.getTimeSlotId());

            return ScheduleDTO.builder()
                    .scheduleId(s.getScheduleId())
                    .classId(s.getClassId())
                    .classCode(sc  != null ? sc.getClassCode()   : "")
                    .className(sc  != null ? sc.getClassName()    : "")
                    .roomId(s.getRoomId())
                    .roomName(room != null ? room.getRoomName()   : "")
                    .timeSlotId(s.getTimeSlotId())
                    .slotName(slot != null ? slot.getSlotName()   : "")
                    .startTime(slot != null ? slot.getStartTime() : null)
                    .endTime(slot   != null ? slot.getEndTime()   : null)
                    .scheduleDate(s.getScheduleDate())
                    .note(s.getNote())
                    .status(s.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }
}
