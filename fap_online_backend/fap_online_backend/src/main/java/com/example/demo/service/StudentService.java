package com.example.demo.service;

import com.example.demo.dto.*;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import com.example.demo.util.SessionStatusResolver;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StudentService {
    
    @Autowired private StudentRepository studentRepository;
    @Autowired private ClassStudentRepository classStudentRepository;
    @Autowired private ScheduleRepository scheduleRepository;
    @Autowired private TimeSlotRepository timeSlotRepository;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private EntityManager entityManager;

    private Student getStudentByUserId(Integer userId) {
        return studentRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    private static final DateTimeFormatter DATE_LABEL_FORMAT = DateTimeFormatter.ofPattern("dd/MM");
    private static final String[] DAY_LABELS = {"MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"};

    public WeeklyTimetableDto getWeeklyTimetable(Integer userId, LocalDate fromDate, LocalDate toDate) {
        Student student = getStudentByUserId(userId);
        List<ClassStudent> classStudents = classStudentRepository.findByStudentId(student.getStudentId());
        List<Integer> classIds = classStudents.stream().map(ClassStudent::getClassId).collect(Collectors.toList());

        LocalDate weekStart = fromDate != null ? fromDate : LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = toDate != null ? toDate : weekStart.plusDays(6);

        WeeklyTimetableDto weekly = new WeeklyTimetableDto();
        weekly.setYear(weekStart.getYear());
        weekly.setWeekStart(weekStart);
        weekly.setWeekEnd(weekEnd);
        weekly.setWeekLabel(formatWeekLabel(weekStart, weekEnd));
        weekly.setSlots(buildSlotSummaries());
        weekly.setDays(buildDayColumns(weekStart, weekEnd));

        if (classIds.isEmpty()) {
            weekly.setEntries(new ArrayList<>());
            return weekly;
        }

        List<Object[]> rows = scheduleRepository.findTimetableEntries(
                classIds, student.getStudentId(), weekStart, weekEnd);
        weekly.setEntries(rows.stream().map(this::mapTimetableRow).collect(Collectors.toList()));
        return weekly;
    }

    private List<TimeSlotSummaryDto> buildSlotSummaries() {
        return timeSlotRepository.findByStatusOrderByStartTimeAsc("Active").stream()
                .map(slot -> new TimeSlotSummaryDto(
                        slot.getSlotCode(),
                        formatTimeRange(slot.getStartTime(), slot.getEndTime())))
                .collect(Collectors.toList());
    }

    private List<DayColumnDto> buildDayColumns(LocalDate weekStart, LocalDate weekEnd) {
        List<DayColumnDto> days = new ArrayList<>();
        LocalDate current = weekStart;
        int index = 0;
        while (!current.isAfter(weekEnd)) {
            String dayLabel = index < DAY_LABELS.length ? DAY_LABELS[index] : current.getDayOfWeek().name().substring(0, 3);
            days.add(new DayColumnDto(current, dayLabel, current.format(DATE_LABEL_FORMAT)));
            current = current.plusDays(1);
            index++;
        }
        return days;
    }

    private TimetableDto mapTimetableRow(Object[] row) {
        LocalDate scheduleDate = toLocalDate(row[1]);
        LocalTime startTime = toLocalTime(row[4]);
        LocalTime endTime = toLocalTime(row[5]);
        String scheduleStatus = row[10] != null ? row[10].toString() : null;
        String attendanceStatus = row[11] != null ? row[11].toString() : null;

        SessionStatusResolver.SessionStatus sessionStatus = SessionStatusResolver.resolve(
                scheduleStatus, attendanceStatus, scheduleDate, startTime);

        TimetableDto dto = new TimetableDto();
        dto.setScheduleId(((Number) row[0]).intValue());
        dto.setScheduleDate(scheduleDate);
        dto.setRoomCode((String) row[2]);
        dto.setSlotCode((String) row[3]);
        dto.setSlotTime(formatTimeRange(startTime, endTime));
        dto.setClassCode((String) row[6]);
        dto.setSubjectCode((String) row[7]);
        dto.setSubjectName((String) row[8]);
        dto.setTeacherCode((String) row[9]);
        dto.setScheduleStatus(sessionStatus.scheduleStatus());
        dto.setAttendanceStatus(attendanceStatus);
        dto.setAttendanceLabel(sessionStatus.statusLabel());
        dto.setStatusType(sessionStatus.statusType());
        dto.setStatusLabel(sessionStatus.statusLabel());
        return dto;
    }

    private LocalDate toLocalDate(Object value) {
        if (value instanceof LocalDate localDate) {
            return localDate;
        }
        if (value instanceof java.sql.Date sqlDate) {
            return sqlDate.toLocalDate();
        }
        return LocalDate.parse(value.toString());
    }

    private LocalTime toLocalTime(Object value) {
        if (value instanceof LocalTime localTime) {
            return localTime;
        }
        if (value instanceof java.sql.Time sqlTime) {
            return sqlTime.toLocalTime();
        }
        return LocalTime.parse(value.toString());
    }

    private String formatWeekLabel(LocalDate weekStart, LocalDate weekEnd) {
        return weekStart.format(DATE_LABEL_FORMAT) + " To " + weekEnd.format(DATE_LABEL_FORMAT);
    }

    private String formatTimeRange(LocalTime start, LocalTime end) {
        return "(" + formatTime(start) + "-" + formatTime(end) + ")";
    }

    private String formatTime(LocalTime time) {
        return time.getHour() + ":" + String.format("%02d", time.getMinute());
    }

    public List<GradeDto> getMarkReport(Integer userId) {
        Student student = getStudentByUserId(userId);
        
        // Native query to get FinalGrades joined with Class and Subject
        String sql = "SELECT c.ClassCode, s.SubjectCode, s.SubjectName, fg.FinalScore, fg.Result " +
                     "FROM FinalGrades fg " +
                     "JOIN Classes c ON fg.ClassId = c.ClassId " +
                     "JOIN Subjects s ON c.SubjectId = s.SubjectId " +
                     "WHERE fg.StudentId = :studentId";
        
        List<Object[]> results = entityManager.createNativeQuery(sql)
                .setParameter("studentId", student.getStudentId())
                .getResultList();
                
        List<GradeDto> grades = new ArrayList<>();
        for (Object[] row : results) {
            GradeDto dto = new GradeDto();
            dto.setClassCode((String) row[0]);
            dto.setSubjectCode((String) row[1]);
            dto.setSubjectName((String) row[2]);
            dto.setFinalScore(row[3] != null ? new BigDecimal(row[3].toString()) : null);
            dto.setResult((String) row[4]);
            grades.add(dto);
        }
        return grades;
    }

    public List<AttendanceDto> getAttendanceReport(Integer userId) {
        Student student = getStudentByUserId(userId);
        
        String sql = "SELECT sub.SubjectCode, sub.SubjectName, " +
                     "COUNT(s.ScheduleId) as TotalSlots, " +
                     "SUM(CASE WHEN a.Status IN ('AbsentWithPermission', 'AbsentWithoutPermission') THEN 1 ELSE 0 END) as AbsentSlots " +
                     "FROM Schedules s " +
                     "JOIN Classes c ON s.ClassId = c.ClassId " +
                     "JOIN Subjects sub ON c.SubjectId = sub.SubjectId " +
                     "JOIN ClassStudents cs ON c.ClassId = cs.ClassId AND cs.StudentId = :studentId AND cs.Status = 'Active' " +
                     "LEFT JOIN Attendances a ON s.ScheduleId = a.ScheduleId AND a.StudentId = :studentId " +
                     "WHERE s.Status = 'Completed' " +
                     "GROUP BY sub.SubjectCode, sub.SubjectName";

        List<Object[]> results = entityManager.createNativeQuery(sql)
                .setParameter("studentId", student.getStudentId())
                .getResultList();

        List<AttendanceDto> dtos = new ArrayList<>();
        for (Object[] row : results) {
            AttendanceDto dto = new AttendanceDto();
            dto.setSubjectCode((String) row[0]);
            dto.setSubjectName((String) row[1]);
            int total = ((Number) row[2]).intValue();
            int absent = ((Number) row[3]).intValue();
            dto.setTotalSlots(total);
            dto.setAbsentSlots(absent);
            dto.setAbsentPercent(total > 0 ? Math.round((double) absent / total * 10000.0) / 100.0 : 0.0);
            dtos.add(dto);
        }
        return dtos;
    }

    public TranscriptDto getAcademicTranscript(Integer userId) {
        Student student = getStudentByUserId(userId);
        
        String sql = "SELECT sem.SemesterName, sub.SubjectCode, sub.SubjectName, fg.FinalScore, fg.Result " +
                     "FROM FinalGrades fg " +
                     "JOIN Classes c ON fg.ClassId = c.ClassId " +
                     "JOIN Semesters sem ON c.SemesterId = sem.SemesterId " +
                     "JOIN Subjects sub ON c.SubjectId = sub.SubjectId " +
                     "WHERE fg.StudentId = :studentId " +
                     "ORDER BY sem.StartDate DESC";

        List<Object[]> results = entityManager.createNativeQuery(sql)
                .setParameter("studentId", student.getStudentId())
                .getResultList();

        TranscriptDto dto = new TranscriptDto();
        List<GradeDto> grades = new ArrayList<>();
        
        for (Object[] row : results) {
            if (dto.getSemesterName() == null) {
                dto.setSemesterName((String) row[0]);
            }
            GradeDto gd = new GradeDto();
            gd.setSubjectCode((String) row[1]);
            gd.setSubjectName((String) row[2]);
            gd.setFinalScore(row[3] != null ? new BigDecimal(row[3].toString()) : null);
            gd.setResult((String) row[4]);
            grades.add(gd);
        }
        dto.setSubjects(grades);
        return dto;
    }

    public DashboardSummaryDto getDashboardSummary(Integer userId) {
        DashboardSummaryDto dto = new DashboardSummaryDto();
        List<NotificationDto> notifs = getNotifications(userId);
        dto.setUnreadNotifications((int) notifs.stream().filter(n -> !n.getIsRead()).count());
        dto.setNextClassSubject("PRM392");
        dto.setNextClassRoom("AL-R201");
        dto.setNextClassTime("07:30 - 09:50");
        return dto;
    }

    public List<NotificationDto> getNotifications(Integer userId) {
        List<Notification> notifs = notificationRepository.findByUserId(userId);
        return notifs.stream().map(n -> {
            NotificationDto dto = new NotificationDto();
            dto.setNotificationId(n.getNotificationId());
            dto.setTitle(n.getTitle());
            dto.setContent(n.getContent());
            dto.setType(n.getTargetType());
            dto.setCreatedAt(n.getCreatedAt());
            dto.setIsRead(false); 
            return dto;
        }).collect(Collectors.toList());
    }
}

