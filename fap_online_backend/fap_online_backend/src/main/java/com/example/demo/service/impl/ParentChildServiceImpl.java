package com.example.demo.service.impl;

import com.example.demo.dto.*;
import com.example.demo.entity.*;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.repository.*;
import com.example.demo.service.ParentChildService;
import com.example.demo.service.ParentValidationService;
import com.example.demo.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.example.demo.util.SecurityUtils;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParentChildServiceImpl implements ParentChildService {

    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    
    private final ScheduleRepository scheduleRepository;
    private final StudentGradeRepository studentGradeRepository;
    private final StudentFeeRepository studentFeeRepository;
    
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final ClassGradeComponentRepository classGradeComponentRepository;
    private final GradeComponentRepository gradeComponentRepository;
    private final FeeTypeRepository feeTypeRepository;
    private final FinalGradeRepository finalGradeRepository;
    private final AttendanceService attendanceService;

    private final ParentValidationService parentValidationService;

    @Override
    public List<ChildDetailDTO> getMyChildren() {
        Integer userId = SecurityUtils.extractUserId();
        Parent parent = parentRepository.findByUserId(userId).orElse(null);

        if (parent == null) {
            return Collections.emptyList();
        }

        List<Integer> studentIds = parentStudentRepository.findStudentIdsByParentId(parent.getParentId());
        if (studentIds.isEmpty()) return Collections.emptyList();

        List<Student> students = studentRepository.findAllByStudentIdIn(studentIds);
        List<Integer> userIds = students.stream().map(Student::getUserId).collect(Collectors.toList());
        Map<Integer, User> userMap = userRepository.findAllById(userIds)
                .stream().collect(Collectors.toMap(User::getUserId, u -> u));

        return students.stream().map(student -> mapToChildDetailDTO(student, userMap.get(student.getUserId()))).collect(Collectors.toList());
    }

    @Override
    public ChildDetailDTO getChildDetail(Integer studentId) {
        Integer userId = SecurityUtils.extractUserId();
        parentValidationService.validateParentOwnsStudent(studentId);
        
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));
        User user = userRepository.findById(student.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                
        return mapToChildDetailDTO(student, user);
    }

    @Override
    public List<WeeklyTimetableDTO> getChildTimetable(Integer studentId, LocalDate startDate, LocalDate endDate) {
        Integer userId = SecurityUtils.extractUserId();
        parentValidationService.validateParentOwnsStudent(studentId);
        
        LocalDate finalStartDate = startDate != null ? startDate : LocalDate.now().minusDays(LocalDate.now().getDayOfWeek().getValue() - 1);
        LocalDate finalEndDate = endDate != null ? endDate : finalStartDate.plusDays(6);

        List<Schedule> schedules = scheduleRepository.findWeeklySchedulesForStudents(List.of(studentId), finalStartDate, finalEndDate);
        
        return schedules.stream().map(s -> {
            SchoolClass schoolClass = schoolClassRepository.findById(s.getClassId()).orElse(null);
            Subject subject = schoolClass != null ? subjectRepository.findById(schoolClass.getSubjectId()).orElse(null) : null;
            Room room = roomRepository.findById(s.getRoomId()).orElse(null);
            TimeSlot timeSlot = timeSlotRepository.findById(s.getTimeSlotId()).orElse(null);
            
            return WeeklyTimetableDTO.builder()
                    .scheduleDate(s.getScheduleDate())
                    .subjectCode(subject != null ? subject.getSubjectCode() : "")
                    .roomName(room != null ? room.getRoomName() : "")
                    .timeSlot(timeSlot != null ? timeSlot.getSlotName() : "")
                    .startTime(timeSlot != null ? timeSlot.getStartTime() : null)
                    .endTime(timeSlot != null ? timeSlot.getEndTime() : null)
                    .status(s.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }

    @Override
    public List<AttendanceReportDTO> getChildAttendance(Integer studentId, Integer subjectId, Integer semesterId) {
        parentValidationService.validateParentOwnsStudent(studentId);
        return attendanceService.getAttendanceReport(
                studentId,
                LocalDate.of(2000, 1, 1),
                LocalDate.now());
    }

    @Override
    public List<GradeReportDTO> getChildGrades(Integer studentId, Integer semesterId) {
        Integer userId = SecurityUtils.extractUserId();
        parentValidationService.validateParentOwnsStudent(studentId);
        
        List<StudentGrade> grades = semesterId == null
                ? studentGradeRepository.findRecentGradesForStudents(
                        List.of(studentId), org.springframework.data.domain.PageRequest.of(0, 100))
                : studentGradeRepository.findBySemester(studentId, semesterId);
        
        return grades.stream().map(g -> {
            SchoolClass schoolClass = schoolClassRepository.findById(g.getClassId()).orElse(null);
            Subject subject = schoolClass != null ? subjectRepository.findById(schoolClass.getSubjectId()).orElse(null) : null;
            
            ClassGradeComponent cgc = classGradeComponentRepository.findById(g.getClassGradeComponentId()).orElse(null);
            GradeComponent gc = cgc != null ? gradeComponentRepository.findById(cgc.getGradeComponentId()).orElse(null) : null;
            
            return GradeReportDTO.builder()
                    .subjectCode(subject != null ? subject.getSubjectCode() : "")
                    .gradeComponent(gc != null ? gc.getComponentName() : "")
                    .score(g.getScore())
                    .weight(cgc != null ? cgc.getWeight() : null)
                    .build();
        }).collect(Collectors.toList());
    }

    @Override
    public List<TranscriptDTO> getChildTranscript(Integer studentId) {
        Integer userId = SecurityUtils.extractUserId();
        parentValidationService.validateParentOwnsStudent(studentId);
        
        // Ensure you have FinalGradeRepository injected
        List<FinalGrade> grades = finalGradeRepository.findByStudentId(studentId);
        
        return grades.stream().map(g -> {
            SchoolClass schoolClass = schoolClassRepository.findById(g.getClassId()).orElse(null);
            Subject subject = schoolClass != null ? subjectRepository.findById(schoolClass.getSubjectId()).orElse(null) : null;
            
            return TranscriptDTO.builder()
                    .subjectCode(subject != null ? subject.getSubjectCode() : "")
                    .subjectName(subject != null ? subject.getSubjectName() : "")
                    .finalScore(g.getFinalScore())
                    .status(g.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }

    @Override
    public List<FeeDTO> getChildFees(Integer studentId, Integer semesterId) {
        Integer userId = SecurityUtils.extractUserId();
        parentValidationService.validateParentOwnsStudent(studentId);
        List<StudentFee> fees = studentFeeRepository.findByStudentId(studentId);
        if (semesterId != null) {
            fees = fees.stream()
                    .filter(fee -> semesterId.equals(fee.getSemesterId()))
                    .collect(Collectors.toList());
        }
        
        return fees.stream().map(fee -> {
            FeeType feeType = feeTypeRepository.findById(fee.getFeeTypeId()).orElse(null);
            return FeeDTO.builder()
                    .feeId(fee.getStudentFeeId())
                    .feeType(feeType != null ? feeType.getFeeTypeName() : "")
                    .amount(fee.getAmount())
                    .paidAmount(fee.getPaidAmount())
                    .dueDate(fee.getDueDate())
                    .status(fee.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }
    
    private ChildDetailDTO mapToChildDetailDTO(Student student, User user) {
        return ChildDetailDTO.builder()
                .studentId(student.getStudentId())
                .studentCode(student.getStudentCode())
                .fullName(user != null ? user.getFullName() : null)
                .email(user != null ? user.getEmail() : null)
                .phone(user != null ? user.getPhone() : null)
                .dateOfBirth(user != null ? user.getDateOfBirth() : null)
                .gender(user != null ? user.getGender() : null)
                .avatarUrl(user != null ? user.getAvatarUrl() : null)
                .major(student.getMajor())
                .enrollmentYear(student.getEnrollmentYear())
                .academicStatus(student.getAcademicStatus())
                .build();
    }
}
