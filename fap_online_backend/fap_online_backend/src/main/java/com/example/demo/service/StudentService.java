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
    @Autowired private SchoolClassRepository schoolClassRepository;
    @Autowired private SubjectRepository subjectRepository;
    @Autowired private EntityManager entityManager;

    private Student getStudentByUserId(Integer userId) {
        return studentRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    private static final DateTimeFormatter DATE_LABEL_FORMAT = DateTimeFormatter.ofPattern("dd/MM");
    private static final String[] DAY_LABELS = {"MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"};

    public StudentWeeklyTimetableDto getWeeklyTimetable(Integer userId, LocalDate fromDate, LocalDate toDate) {
        Student student = getStudentByUserId(userId);
        List<ClassStudent> classStudents = classStudentRepository.findByStudentId(student.getStudentId());
        List<Integer> classIds = classStudents.stream().map(ClassStudent::getClassId).collect(Collectors.toList());

        LocalDate weekStart = fromDate != null ? fromDate : LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = toDate != null ? toDate : weekStart.plusDays(6);

        StudentWeeklyTimetableDto weekly = new StudentWeeklyTimetableDto();
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

        String sql = "SELECT c.ClassId, c.ClassCode, s.SubjectCode, s.SubjectName, fg.FinalScore, fg.Result " +
                     "FROM FinalGrades fg " +
                     "JOIN Classes c ON fg.ClassId = c.ClassId " +
                     "JOIN Subjects s ON c.SubjectId = s.SubjectId " +
                     "WHERE fg.StudentId = :studentId";

        List<Object[]> results = entityManager.createNativeQuery(sql)
                .setParameter("studentId", student.getStudentId())
                .getResultList();

        String componentSql = "SELECT gc.ComponentName, cgc.Weight, sg.Score " +
                "FROM StudentGrades sg " +
                "JOIN ClassGradeComponents cgc ON sg.ClassGradeComponentId = cgc.ClassGradeComponentId " +
                "JOIN GradeComponents gc ON cgc.GradeComponentId = gc.GradeComponentId " +
                "WHERE sg.StudentId = :studentId AND sg.ClassId = :classId " +
                "ORDER BY cgc.ClassGradeComponentId";

        String attendanceSql = "SELECT COUNT(sch.ScheduleId) as TotalSlots, " +
                "SUM(CASE WHEN a.Status IN ('AbsentWithPermission', 'AbsentWithoutPermission') THEN 1 ELSE 0 END) as AbsentSlots " +
                "FROM Schedules sch " +
                "LEFT JOIN Attendances a ON sch.ScheduleId = a.ScheduleId AND a.StudentId = :studentId " +
                "WHERE sch.ClassId = :classId AND sch.Status = 'Completed'";

        List<GradeDto> grades = new ArrayList<>();
        for (Object[] row : results) {
            Integer classId = ((Number) row[0]).intValue();
            GradeDto dto = new GradeDto();
            dto.setClassId(classId);
            dto.setClassCode((String) row[1]);
            dto.setSubjectCode((String) row[2]);
            dto.setSubjectName((String) row[3]);
            dto.setFinalScore(row[4] != null ? new BigDecimal(row[4].toString()) : null);
            dto.setResult((String) row[5]);

            List<Object[]> attRows = entityManager.createNativeQuery(attendanceSql)
                    .setParameter("studentId", student.getStudentId())
                    .setParameter("classId", classId)
                    .getResultList();
            if (!attRows.isEmpty() && attRows.get(0) != null) {
                Object[] att = attRows.get(0);
                int total = att[0] != null ? ((Number) att[0]).intValue() : 0;
                int absent = att[1] != null ? ((Number) att[1]).intValue() : 0;
                double presentPercent = total > 0
                        ? Math.round(((double) (total - absent) / total) * 10000.0) / 100.0
                        : 0.0;
                dto.setAttendancePercent(presentPercent);
            } else {
                dto.setAttendancePercent(0.0);
            }

            List<Object[]> componentRows = entityManager.createNativeQuery(componentSql)
                    .setParameter("studentId", student.getStudentId())
                    .setParameter("classId", classId)
                    .getResultList();
            List<GradeDto.ComponentGrade> components = new ArrayList<>();
            for (Object[] cRow : componentRows) {
                GradeDto.ComponentGrade component = new GradeDto.ComponentGrade();
                component.setComponentName((String) cRow[0]);
                component.setWeight(cRow[1] != null ? new BigDecimal(cRow[1].toString()) : BigDecimal.ZERO);
                component.setScore(cRow[2] != null ? new BigDecimal(cRow[2].toString()) : null);
                components.add(component);
            }
            dto.setComponents(components);
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

    public StudentTranscriptDto getAcademicTranscript(Integer userId) {
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

        StudentTranscriptDto dto = new StudentTranscriptDto();
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

    public List<StudentClassDto> getMyClasses(Integer userId) {
        Student student = getStudentByUserId(userId);
        List<ClassStudent> enrollments = classStudentRepository.findByStudentId(student.getStudentId());
        if (enrollments.isEmpty()) {
            return List.of();
        }

        List<Integer> classIds = enrollments.stream()
                .map(ClassStudent::getClassId)
                .distinct()
                .collect(Collectors.toList());

        Map<Integer, SchoolClass> classMap = schoolClassRepository.findAllById(classIds).stream()
                .collect(Collectors.toMap(SchoolClass::getClassId, c -> c));

        List<Integer> subjectIds = classMap.values().stream()
                .map(SchoolClass::getSubjectId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());

        Map<Integer, Subject> subjectMap = subjectRepository.findAllById(subjectIds).stream()
                .collect(Collectors.toMap(Subject::getSubjectId, s -> s));

        List<StudentClassDto> result = new ArrayList<>();
        for (ClassStudent enrollment : enrollments) {
            SchoolClass schoolClass = classMap.get(enrollment.getClassId());
            if (schoolClass == null) {
                continue;
            }
            Subject subject = subjectMap.get(schoolClass.getSubjectId());
            result.add(StudentClassDto.builder()
                    .classId(schoolClass.getClassId())
                    .classCode(schoolClass.getClassCode())
                    .className(schoolClass.getClassName())
                    .subjectCode(subject != null ? subject.getSubjectCode() : null)
                    .subjectName(subject != null ? subject.getSubjectName() : null)
                    .status(enrollment.getStatus() != null ? enrollment.getStatus() : schoolClass.getStatus())
                    .enrolledAt(enrollment.getEnrolledAt())
                    .build());
        }
        return result;
    }

    public DashboardSummaryDto getDashboardSummary(Integer userId) {
        DashboardSummaryDto dto = new DashboardSummaryDto();
        List<StudentNotificationDto> notifs = getNotifications(userId);
        dto.setUnreadNotifications((int) notifs.stream().filter(n -> !n.getIsRead()).count());

        Student student = getStudentByUserId(userId);
        List<ClassStudent> classStudents = classStudentRepository.findByStudentId(student.getStudentId());
        List<Integer> classIds = classStudents.stream()
                .map(ClassStudent::getClassId)
                .collect(Collectors.toList());

        if (classIds.isEmpty()) {
            return dto;
        }

        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        List<Object[]> rows = scheduleRepository.findTimetableEntries(
                classIds, student.getStudentId(), today, today.plusDays(14));

        for (Object[] row : rows) {
            LocalDate scheduleDate = toLocalDate(row[1]);
            LocalTime startTime = toLocalTime(row[4]);
            LocalTime endTime = toLocalTime(row[5]);
            String scheduleStatus = row[10] != null ? row[10].toString() : null;
            if ("Cancelled".equalsIgnoreCase(scheduleStatus)) {
                continue;
            }
            boolean upcoming = scheduleDate.isAfter(today)
                    || (scheduleDate.isEqual(today) && (endTime == null || !endTime.isBefore(now)));
            if (!upcoming) {
                continue;
            }

            dto.setNextClassSubject(row[8] != null ? row[8].toString() : null);
            dto.setNextClassRoom(row[2] != null ? row[2].toString() : null);
            dto.setNextClassTime(formatTime(startTime) + " - " + formatTime(endTime));
            break;
        }

        return dto;
    }

    public List<StudentNotificationDto> getNotifications(Integer userId) {
        List<Notification> notifs = notificationRepository.findByUserId(userId);
        return notifs.stream().map(n -> {
            StudentNotificationDto dto = new StudentNotificationDto();
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

