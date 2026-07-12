package com.example.demo.service.impl;

import com.example.demo.dto.*;
import com.example.demo.entity.*;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.repository.*;
import com.example.demo.service.ParentDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import com.example.demo.util.SecurityUtils;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParentDashboardServiceImpl implements ParentDashboardService {

    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final NotificationRecipientRepository notificationRecipientRepository;
    private final ScheduleRepository scheduleRepository;
    private final StudentGradeRepository studentGradeRepository;
    private final StudentFeeRepository studentFeeRepository;
    private final AttendanceRepository attendanceRepository;
    
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final ClassGradeComponentRepository classGradeComponentRepository;
    private final GradeComponentRepository gradeComponentRepository;
    private final FeeTypeRepository feeTypeRepository;

    @Override
    public DashboardResponse getDashboardData() {
        Integer userId = SecurityUtils.extractUserId();
        // Validate and fetch parent based on userId from JWT
        Parent parent = parentRepository.findByUserId(userId).orElse(null);

        // If parent profile does not exist or no children linked, return empty dashboard
        if (parent == null) {
            return DashboardResponse.builder()
                    .children(new ArrayList<>())
                    .unreadNotificationCount(0)
                    .todaySchedules(new ArrayList<>())
                    .recentGrades(new ArrayList<>())
                    .unpaidFees(new ArrayList<>())
                    .attendancePresentCount(0)
                    .attendanceTotalCount(0)
                    .build();
        }

        // Get all students linked to this parent
        List<Integer> studentIds = parentStudentRepository.findStudentIdsByParentId(parent.getParentId());
        
        // Return empty dashboard if no children linked
        if (studentIds.isEmpty()) {
            return DashboardResponse.builder()
                    .children(new ArrayList<>())
                    .unreadNotificationCount(0)
                    .todaySchedules(new ArrayList<>())
                    .recentGrades(new ArrayList<>())
                    .unpaidFees(new ArrayList<>())
                    .attendancePresentCount(0)
                    .attendanceTotalCount(0)
                    .build();
        }

        // Fetch student details
        List<Student> students = studentRepository.findAllByStudentIdIn(studentIds);
        Map<Integer, User> userMap = userRepository.findAllById(
                students.stream().map(Student::getUserId).collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(User::getUserId, u -> u));

        // 1. Children Summary
        List<ChildSummaryDTO> children = students.stream().map(student -> {
            User user = userMap.get(student.getUserId());
            return ChildSummaryDTO.builder()
                    .studentId(student.getStudentId())
                    .studentCode(student.getStudentCode())
                    .fullName(user != null ? user.getFullName() : "")
                    .major(student.getMajor())
                    .academicStatus(student.getAcademicStatus())
                    .build();
        }).collect(Collectors.toList());

        // 2. Unread Notifications Count (for the Parent user)
        int unreadCount = notificationRecipientRepository.countUnreadByUserId(userId);

        // 3. Today's Schedules for all children
        LocalDate today = LocalDate.now();
        List<Schedule> schedules = scheduleRepository.findTodaySchedulesForStudents(studentIds, today);
        List<TodayScheduleDTO> todaySchedules = schedules.stream().map(s -> {
            SchoolClass schoolClass = schoolClassRepository.findById(s.getClassId()).orElse(null);
            Subject subject = schoolClass != null ? subjectRepository.findById(schoolClass.getSubjectId()).orElse(null) : null;
            Room room = roomRepository.findById(s.getRoomId()).orElse(null);
            TimeSlot timeSlot = timeSlotRepository.findById(s.getTimeSlotId()).orElse(null);
            
            return TodayScheduleDTO.builder()
                    .studentId(null) // Generic schedule for today across children
                    .studentName("")
                    .subjectCode(subject != null ? subject.getSubjectCode() : "")
                    .roomName(room != null ? room.getRoomName() : "")
                    .timeSlot(timeSlot != null ? timeSlot.getStartTime() + " - " + timeSlot.getEndTime() : "")
                    .build();
        }).collect(Collectors.toList());

        // 4. Recent Grades (Limit to 5 overall)
        List<StudentGrade> recentStudentGrades = studentGradeRepository.findRecentGradesForStudents(studentIds, PageRequest.of(0, 5));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        
        List<RecentGradeDTO> recentGrades = recentStudentGrades.stream().map(g -> {
            Student student = students.stream().filter(st -> st.getStudentId().equals(g.getStudentId())).findFirst().orElse(null);
            String studentName = "";
            if (student != null && userMap.containsKey(student.getUserId())) {
                studentName = userMap.get(student.getUserId()).getFullName();
            }
            
            SchoolClass schoolClass = schoolClassRepository.findById(g.getClassId()).orElse(null);
            Subject subject = schoolClass != null ? subjectRepository.findById(schoolClass.getSubjectId()).orElse(null) : null;
            
            ClassGradeComponent cgc = classGradeComponentRepository.findById(g.getClassGradeComponentId()).orElse(null);
            GradeComponent gc = cgc != null ? gradeComponentRepository.findById(cgc.getGradeComponentId()).orElse(null) : null;
            
            return RecentGradeDTO.builder()
                    .studentId(g.getStudentId())
                    .studentName(studentName)
                    .subjectCode(subject != null ? subject.getSubjectCode() : "")
                    .gradeComponent(gc != null ? gc.getComponentName() : "")
                    .score(g.getScore())
                    .enteredAt(g.getEnteredAt() != null ? g.getEnteredAt().format(formatter) : "")
                    .build();
        }).collect(Collectors.toList());

        // 5. Unpaid Fees for all children
        List<StudentFee> unpaidStudentFees = studentFeeRepository.findUnpaidFeesForStudents(studentIds);
        List<UnpaidFeeDTO> unpaidFees = unpaidStudentFees.stream().map(fee -> {
             Student student = students.stream().filter(st -> st.getStudentId().equals(fee.getStudentId())).findFirst().orElse(null);
             String studentName = "";
             if (student != null && userMap.containsKey(student.getUserId())) {
                 studentName = userMap.get(student.getUserId()).getFullName();
             }
             
             FeeType feeType = feeTypeRepository.findById(fee.getFeeTypeId()).orElse(null);
             
             return UnpaidFeeDTO.builder()
                     .studentId(fee.getStudentId())
                     .studentName(studentName)
                     .feeType(feeType != null ? feeType.getFeeTypeName() : "")
                     .amount(fee.getAmount())
                     .paidAmount(fee.getPaidAmount())
                     .dueDate(fee.getDueDate() != null ? fee.getDueDate().toString() : "")
                     .build();
        }).collect(Collectors.toList());

        List<Attendance> attendances = attendanceRepository.findByStudentIdIn(studentIds);
        int attendanceTotalCount = attendances.size();
        int attendancePresentCount = (int) attendances.stream()
                .filter(attendance -> "PRESENT".equalsIgnoreCase(attendance.getStatus())
                        || "LATE".equalsIgnoreCase(attendance.getStatus()))
                .count();

        return DashboardResponse.builder()
                .children(children)
                .unreadNotificationCount(unreadCount)
                .todaySchedules(todaySchedules)
                .recentGrades(recentGrades)
                .unpaidFees(unpaidFees)
                .attendancePresentCount(attendancePresentCount)
                .attendanceTotalCount(attendanceTotalCount)
                .build();
    }
}
