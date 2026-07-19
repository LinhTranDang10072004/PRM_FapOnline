package com.example.demo.service.impl;

import com.example.demo.dto.*;
import com.example.demo.entity.*;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.*;
import com.example.demo.service.StaffClassService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StaffClassServiceImpl implements StaffClassService {

    private static final Set<String> VALID_CLASS_STATUSES =
            Set.of("Draft", "Open", "In Progress", "Completed", "Cancelled");

    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    private final SemesterRepository semesterRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final ClassStudentRepository classStudentRepository;
    private final ScheduleRepository scheduleRepository;
    private final StudentGradeRepository studentGradeRepository;
    private final AttendanceRepository attendanceRepository;

    // ============================== READ ==============================

    @Override
    public List<ClassDTO> getAllClasses(Integer semesterId) {
        List<SchoolClass> classes = semesterId != null
                ? schoolClassRepository.findBySemesterId(semesterId)
                : schoolClassRepository.findAll();

        if (classes.isEmpty()) {
            return Collections.emptyList();
        }

        Map<Integer, Subject> subjectMap = subjectRepository.findAllById(
                classes.stream().map(SchoolClass::getSubjectId).distinct().collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(Subject::getSubjectId, s -> s));

        Map<Integer, Semester> semesterMap = semesterRepository.findAllById(
                classes.stream().map(SchoolClass::getSemesterId).distinct().collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(Semester::getSemesterId, s -> s));

        List<Integer> teacherIds = classes.stream()
                .map(SchoolClass::getMainTeacherId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        Map<Integer, Teacher> teacherMap = teacherIds.isEmpty() ? Map.of() : teacherRepository.findAllById(teacherIds)
                .stream().collect(Collectors.toMap(Teacher::getTeacherId, t -> t));
        Map<Integer, User> teacherUserMap = teacherMap.isEmpty() ? Map.of() : userRepository.findAllById(
                teacherMap.values().stream().map(Teacher::getUserId).distinct().collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(User::getUserId, u -> u));

        return classes.stream()
                .map(sc -> mapToDTO(sc, subjectMap.get(sc.getSubjectId()), semesterMap.get(sc.getSemesterId()),
                        sc.getMainTeacherId() != null ? teacherMap.get(sc.getMainTeacherId()) : null,
                        teacherUserMap))
                .collect(Collectors.toList());
    }

    @Override
    public ClassDTO getClassById(Integer classId) {
        SchoolClass schoolClass = getClassOrThrow(classId);
        Subject subject = subjectRepository.findById(schoolClass.getSubjectId()).orElse(null);
        Semester semester = semesterRepository.findById(schoolClass.getSemesterId()).orElse(null);
        Teacher teacher = schoolClass.getMainTeacherId() != null
                ? teacherRepository.findById(schoolClass.getMainTeacherId()).orElse(null)
                : null;
        Map<Integer, User> teacherUserMap = teacher != null
                ? userRepository.findById(teacher.getUserId()).map(u -> Map.of(u.getUserId(), u)).orElse(Map.of())
                : Map.of();

        return mapToDTO(schoolClass, subject, semester, teacher, teacherUserMap);
    }

    // ============================== UC-13: Manage Classes ==============================

    @Override
    public ClassDTO createClass(CreateClassRequest request) {
        String classCode = request.getClassCode().trim();
        if (schoolClassRepository.existsByClassCode(classCode)) {
            throw new ValidationException("Mã lớp đã tồn tại");
        }

        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy môn học"));
        if (!"Active".equalsIgnoreCase(subject.getStatus())) {
            throw new ValidationException("Môn học không ở trạng thái hoạt động");
        }

        Semester semester = semesterRepository.findById(request.getSemesterId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học kỳ"));
        if (!"Active".equalsIgnoreCase(semester.getStatus())) {
            throw new ValidationException("Học kỳ không ở trạng thái hoạt động, không thể tạo lớp mới");
        }

        String status = resolveStatus(request.getStatus(), "Draft");

        LocalDateTime now = LocalDateTime.now();
        SchoolClass schoolClass = new SchoolClass();
        schoolClass.setClassCode(classCode);
        schoolClass.setClassName(request.getClassName());
        schoolClass.setSubjectId(subject.getSubjectId());
        schoolClass.setSemesterId(semester.getSemesterId());
        schoolClass.setMaxStudents(request.getMaxStudents());
        schoolClass.setStatus(status);
        schoolClass.setCreatedAt(now);

        SchoolClass saved = schoolClassRepository.save(schoolClass);
        return mapToDTO(saved, subject, semester, null, Map.of());
    }

    @Override
    public ClassDTO updateClass(Integer classId, UpdateClassRequest request) {
        SchoolClass schoolClass = getClassOrThrow(classId);
        assertNotLocked(schoolClass, "chỉnh sửa");

        String classCode = request.getClassCode().trim();
        if (schoolClassRepository.existsByClassCodeAndClassIdNot(classCode, classId)) {
            throw new ValidationException("Mã lớp đã tồn tại");
        }

        long currentStudents = classStudentRepository.countByClassId(classId);
        if (request.getMaxStudents() < currentStudents) {
            throw new ValidationException(
                    "Sĩ số tối đa mới (" + request.getMaxStudents() + ") nhỏ hơn số sinh viên hiện tại (" + currentStudents + ")");
        }

        String newStatus = request.getStatus() != null ? resolveStatus(request.getStatus(), null) : schoolClass.getStatus();

        schoolClass.setClassCode(classCode);
        schoolClass.setClassName(request.getClassName());
        schoolClass.setMaxStudents(request.getMaxStudents());
        schoolClass.setStatus(newStatus);
        schoolClass.setUpdatedAt(LocalDateTime.now());

        SchoolClass saved = schoolClassRepository.save(schoolClass);
        return getClassById(saved.getClassId());
    }

    @Override
    public ClassDTO cancelClass(Integer classId) {
        SchoolClass schoolClass = getClassOrThrow(classId);

        if ("Cancelled".equalsIgnoreCase(schoolClass.getStatus())) {
            throw new ValidationException("Lớp đã ở trạng thái Cancelled");
        }

        // Note: this is always a soft delete (status change). The system never
        // hard-deletes a Class row, so the "không được xóa cứng nếu đã có điểm
        // danh/điểm" rule is satisfied by construction — cancelling is always safe.
        schoolClass.setStatus("Cancelled");
        schoolClass.setUpdatedAt(LocalDateTime.now());
        schoolClassRepository.save(schoolClass);

        return getClassById(classId);
    }

    // ============================== UC-15: Assign Teacher ==============================

    @Override
    public ClassDTO assignTeacher(Integer classId, AssignTeacherRequest request) {
        SchoolClass schoolClass = getClassOrThrow(classId);
        assertNotLocked(schoolClass, "phân công giáo viên");

        Teacher teacher = teacherRepository.findById(request.getTeacherId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy giáo viên"));

        User teacherUser = userRepository.findById(teacher.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản của giáo viên"));
        if (!"Active".equalsIgnoreCase(teacherUser.getStatus())) {
            throw new ValidationException("Giáo viên không ở trạng thái hoạt động");
        }

        boolean isReassignment = schoolClass.getMainTeacherId() != null
                && !schoolClass.getMainTeacherId().equals(teacher.getTeacherId());

        if (isReassignment && classHasGradesOrAttendance(classId)) {
            throw new ValidationException(
                    "Lớp đã có điểm danh hoặc điểm, không thể đổi giáo viên (trừ khi có quyền đặc biệt)");
        }

        List<Schedule> targetSchedules = scheduleRepository.findByClassId(classId);
        List<Integer> otherClassIds = schoolClassRepository.findByMainTeacherId(teacher.getTeacherId())
                .stream()
                .map(SchoolClass::getClassId)
                .filter(id -> !id.equals(classId))
                .collect(Collectors.toList());
        List<Schedule> teacherOtherSchedules = otherClassIds.isEmpty()
                ? Collections.emptyList()
                : scheduleRepository.findByClassIdIn(otherClassIds);

        if (hasScheduleConflict(targetSchedules, teacherOtherSchedules)) {
            throw new ValidationException("Giáo viên bị trùng lịch dạy với một lớp khác");
        }

        schoolClass.setMainTeacherId(teacher.getTeacherId());
        schoolClass.setUpdatedAt(LocalDateTime.now());
        schoolClassRepository.save(schoolClass);

        return getClassById(classId);
    }

    // ============================== UC-14: Add / Remove Student ==============================

    @Override
    public List<ClassStudentDTO> getClassStudents(Integer classId) {
        getClassOrThrow(classId);

        List<ClassStudent> enrollments = classStudentRepository.findByClassId(classId);
        if (enrollments.isEmpty()) {
            return Collections.emptyList();
        }

        List<Integer> studentIds = enrollments.stream().map(ClassStudent::getStudentId).collect(Collectors.toList());
        Map<Integer, Student> studentMap = studentRepository.findAllById(studentIds)
                .stream().collect(Collectors.toMap(Student::getStudentId, s -> s));
        Map<Integer, User> userMap = userRepository.findAllById(
                studentMap.values().stream().map(Student::getUserId).distinct().collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(User::getUserId, u -> u));

        return enrollments.stream().map(cs -> {
            Student student = studentMap.get(cs.getStudentId());
            User user = student != null ? userMap.get(student.getUserId()) : null;
            return ClassStudentDTO.builder()
                    .studentId(cs.getStudentId())
                    .studentCode(student != null ? student.getStudentCode() : "")
                    .fullName(user != null ? user.getFullName() : "")
                    .enrolledAt(cs.getEnrolledAt())
                    .status(cs.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }

    @Override
    public ClassStudentDTO addStudentToClass(Integer classId, AddStudentToClassRequest request) {
        SchoolClass schoolClass = getClassOrThrow(classId);
        assertNotLocked(schoolClass, "thêm sinh viên");

        Integer studentId = request.getStudentId();
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sinh viên"));

        User studentUser = userRepository.findById(student.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản của sinh viên"));
        if (!"Active".equalsIgnoreCase(studentUser.getStatus())) {
            throw new ValidationException("Sinh viên không ở trạng thái hoạt động");
        }

        if (classStudentRepository.existsByClassIdAndStudentId(classId, studentId)) {
            throw new ValidationException("Sinh viên đã có trong lớp này");
        }

        long currentCount = classStudentRepository.countByClassId(classId);
        if (currentCount >= schoolClass.getMaxStudents()) {
            throw new ValidationException("Lớp đã đủ sĩ số tối đa (" + schoolClass.getMaxStudents() + ")");
        }

        Semester semester = semesterRepository.findById(schoolClass.getSemesterId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học kỳ của lớp"));
        if (!"Active".equalsIgnoreCase(semester.getStatus())) {
            throw new ValidationException("Không thể thêm sinh viên vào lớp thuộc học kỳ không còn hoạt động");
        }

        List<Schedule> targetSchedules = scheduleRepository.findByClassId(classId);
        List<Integer> otherClassIds = classStudentRepository.findByStudentId(studentId)
                .stream()
                .map(ClassStudent::getClassId)
                .filter(id -> !id.equals(classId))
                .collect(Collectors.toList());
        List<Schedule> studentOtherSchedules = otherClassIds.isEmpty()
                ? Collections.emptyList()
                : scheduleRepository.findByClassIdIn(otherClassIds);

        if (hasScheduleConflict(targetSchedules, studentOtherSchedules)) {
            throw new ValidationException("Sinh viên bị trùng lịch học với một lớp khác");
        }

        ClassStudent classStudent = new ClassStudent();
        classStudent.setClassId(classId);
        classStudent.setStudentId(studentId);
        classStudent.setEnrolledAt(LocalDateTime.now());
        classStudent.setStatus("Active");
        classStudentRepository.save(classStudent);

        return ClassStudentDTO.builder()
                .studentId(studentId)
                .studentCode(student.getStudentCode())
                .fullName(studentUser.getFullName())
                .enrolledAt(classStudent.getEnrolledAt())
                .status(classStudent.getStatus())
                .build();
    }

    @Override
    public void removeStudentFromClass(Integer classId, Integer studentId) {
        getClassOrThrow(classId);

        ClassStudent classStudent = classStudentRepository.findByClassIdAndStudentId(classId, studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Sinh viên không thuộc lớp này"));

        if (studentHasGradesOrAttendance(classId, studentId)) {
            throw new ValidationException(
                    "Sinh viên đã có điểm hoặc điểm danh trong lớp này, không thể xóa. " +
                            "Hãy cập nhật trạng thái ghi danh sang Dropped thay vì xóa.");
        }

        classStudentRepository.delete(classStudent);
    }

    // ============================== Helpers ==============================

    private SchoolClass getClassOrThrow(Integer classId) {
        return schoolClassRepository.findById(classId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp học"));
    }

    private void assertNotLocked(SchoolClass schoolClass, String action) {
        String status = schoolClass.getStatus();
        if ("Completed".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)) {
            throw new ValidationException("Không thể " + action + " cho lớp đã " + status);
        }
    }

    private String resolveStatus(String requestedStatus, String defaultStatus) {
        if (requestedStatus == null || requestedStatus.isBlank()) {
            return defaultStatus;
        }
        boolean valid = VALID_CLASS_STATUSES.stream().anyMatch(s -> s.equalsIgnoreCase(requestedStatus));
        if (!valid) {
            throw new ValidationException(
                    "Trạng thái lớp không hợp lệ. Giá trị cho phép: " + String.join(", ", VALID_CLASS_STATUSES));
        }
        return requestedStatus;
    }

    private boolean classHasGradesOrAttendance(Integer classId) {
        if (studentGradeRepository.existsByClassId(classId)) {
            return true;
        }
        List<Integer> scheduleIds = scheduleRepository.findByClassId(classId)
                .stream().map(Schedule::getScheduleId).collect(Collectors.toList());
        return !scheduleIds.isEmpty() && attendanceRepository.existsByScheduleIdIn(scheduleIds);
    }

    private boolean studentHasGradesOrAttendance(Integer classId, Integer studentId) {
        if (studentGradeRepository.existsByClassIdAndStudentId(classId, studentId)) {
            return true;
        }
        List<Integer> scheduleIds = scheduleRepository.findByClassId(classId)
                .stream().map(Schedule::getScheduleId).collect(Collectors.toList());
        return !scheduleIds.isEmpty() && attendanceRepository.existsByStudentIdAndScheduleIdIn(studentId, scheduleIds);
    }

    /**
     * Two schedule lists conflict if any pair shares the same date AND the same
     * time slot. TimeSlots are defined not to overlap each other (enforced in
     * UC-17), so comparing (date, timeSlotId) pairs is sufficient.
     */
    private boolean hasScheduleConflict(List<Schedule> a, List<Schedule> b) {
        if (a.isEmpty() || b.isEmpty()) {
            return false;
        }
        Set<String> keysA = a.stream()
                .map(s -> s.getScheduleDate() + "#" + s.getTimeSlotId())
                .collect(Collectors.toSet());
        return b.stream().anyMatch(s -> keysA.contains(s.getScheduleDate() + "#" + s.getTimeSlotId()));
    }

    private ClassDTO mapToDTO(SchoolClass sc, Subject subject, Semester semester, Teacher teacher, Map<Integer, User> teacherUserMap) {
        User teacherUser = teacher != null ? teacherUserMap.get(teacher.getUserId()) : null;
        long currentStudents = classStudentRepository.countByClassId(sc.getClassId());

        return ClassDTO.builder()
                .classId(sc.getClassId())
                .classCode(sc.getClassCode())
                .className(sc.getClassName())
                .subjectId(sc.getSubjectId())
                .subjectCode(subject != null ? subject.getSubjectCode() : "")
                .subjectName(subject != null ? subject.getSubjectName() : "")
                .semesterId(sc.getSemesterId())
                .semesterName(semester != null ? semester.getSemesterName() : "")
                .teacherId(sc.getMainTeacherId())
                .teacherName(teacherUser != null ? teacherUser.getFullName() : "")
                .maxStudents(sc.getMaxStudents())
                .currentStudents((int) currentStudents)
                .status(sc.getStatus())
                .build();
    }
}