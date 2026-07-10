package com.example.demo.config;

import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ParentRepository parentRepository;
    private final StudentRepository studentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final SemesterRepository semesterRepository;
    private final SubjectRepository subjectRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final ScheduleRepository scheduleRepository;
    private final GradeComponentRepository gradeComponentRepository;
    private final ClassGradeComponentRepository classGradeComponentRepository;
    private final StudentGradeRepository studentGradeRepository;
    private final FeeTypeRepository feeTypeRepository;
    private final StudentFeeRepository studentFeeRepository;
    private final NotificationRepository notificationRepository;
    private final NotificationRecipientRepository notificationRecipientRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() > 0) {
            System.out.println("Database already contains users. Skipping seed.");
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        System.out.println("Starting Database Seeding...");

        // 1. MASTER DATA
        Semester semester = new Semester();
        semester.setSemesterName("Fall 2026");
        semester.setSemesterCode("FA26");
        semester.setAcademicYear("2026");
        semester.setStatus("Active");
        semester.setStartDate(LocalDate.of(2026, 9, 1));
        semester.setEndDate(LocalDate.of(2026, 12, 31));
        semester.setCreatedAt(now);
        semester = semesterRepository.save(semester);

        Subject prj301 = new Subject();
        prj301.setSubjectCode("PRJ301");
        prj301.setSubjectName("Java Web Development");
        prj301.setCredits(3);
        prj301.setStatus("Active");
        prj301.setCreatedAt(now);
        prj301 = subjectRepository.save(prj301);

        Subject swd392 = new Subject();
        swd392.setSubjectCode("SWD392");
        swd392.setSubjectName("Software Architecture and Design");
        swd392.setCredits(3);
        swd392.setStatus("Active");
        swd392.setCreatedAt(now);
        swd392 = subjectRepository.save(swd392);

        Room de205 = new Room();
        de205.setRoomCode("DE205");
        de205.setRoomName("DE-205");
        de205.setCapacity(30);
        de205.setStatus("Active");
        de205 = roomRepository.save(de205);

        TimeSlot slot1 = new TimeSlot();
        slot1.setSlotCode("SLOT1");
        slot1.setSlotName("Slot 1");
        slot1.setStartTime(LocalTime.of(7, 30));
        slot1.setEndTime(LocalTime.of(9, 50));
        slot1.setStatus("Active");
        slot1 = timeSlotRepository.save(slot1);

        TimeSlot slot2 = new TimeSlot();
        slot2.setSlotCode("SLOT2");
        slot2.setSlotName("Slot 2");
        slot2.setStartTime(LocalTime.of(10, 0));
        slot2.setEndTime(LocalTime.of(12, 20));
        slot2.setStatus("Active");
        slot2 = timeSlotRepository.save(slot2);

        GradeComponent pt = new GradeComponent();
        pt.setComponentName("Progress Test 1");
        pt.setDefaultWeight(new BigDecimal("10.0"));
        pt.setIsActive(true);
        pt = gradeComponentRepository.save(pt);

        GradeComponent fe = new GradeComponent();
        fe.setComponentName("Final Exam");
        fe.setDefaultWeight(new BigDecimal("40.0"));
        fe.setIsActive(true);
        fe = gradeComponentRepository.save(fe);

        FeeType tuition = new FeeType();
        tuition.setFeeTypeName("Tuition Fee Fall 2026");
        tuition.setIsActive(true);
        tuition = feeTypeRepository.save(tuition);

        // 2. USERS
        User parentUser = new User();
        parentUser.setFullName("Le Thi B (Parent)");
        parentUser.setEmail("parent@fpt.edu.vn");
        parentUser.setPhone("0909123456");
        parentUser.setAddress("123 Ha Noi");
        parentUser.setGender("FEMALE");
        parentUser.setPasswordHash(passwordEncoder.encode("123456"));
        parentUser.setStatus("ACTIVE");
        parentUser.setUsername("parent1");
        parentUser.setCreatedAt(now);
        parentUser = userRepository.save(parentUser);

        User studentUser = new User();
        studentUser.setFullName("Nguyen Van A (Student)");
        studentUser.setEmail("student@fpt.edu.vn");
        studentUser.setPhone("0912345678");
        studentUser.setGender("MALE");
        studentUser.setPasswordHash(passwordEncoder.encode("123456"));
        studentUser.setStatus("ACTIVE");
        studentUser.setUsername("student1");
        studentUser.setCreatedAt(now);
        studentUser = userRepository.save(studentUser);

        // 3. PROFILES & RELATIONSHIPS
        Parent parent = new Parent();
        parent.setUserId(parentUser.getUserId());
        parent.setParentCode("P123");
        parent.setCreatedAt(now);
        parent = parentRepository.save(parent);

        Student student = new Student();
        student.setUserId(studentUser.getUserId());
        student.setStudentCode("SE18001");
        student.setMajor("Software Engineering");
        student.setEnrollmentYear(2022);
        student.setAcademicStatus("STUDYING");
        student.setCreatedAt(now);
        student = studentRepository.save(student);

        ParentStudent ps = new ParentStudent();
        ps.setParentId(parent.getParentId());
        ps.setStudentId(student.getStudentId());
        ps.setRelationship("Mother");
        ps.setIsPrimaryContact(true);
        ps.setCreatedAt(now);
        parentStudentRepository.save(ps);

        // 4. CLASSES & GRADES SETUP
        SchoolClass classSe = new SchoolClass();
        classSe.setClassName("SE1801");
        classSe.setSubjectId(prj301.getSubjectId());
        classSe.setSemesterId(semester.getSemesterId());
        classSe.setStatus("Active");
        classSe.setClassCode("SE1801");
        classSe.setMaxStudents(30);
        classSe.setCreatedAt(now);
        classSe = schoolClassRepository.save(classSe);

        ClassGradeComponent cgcPt = new ClassGradeComponent();
        cgcPt.setClassId(classSe.getClassId());
        cgcPt.setGradeComponentId(pt.getGradeComponentId());
        cgcPt.setWeight(new BigDecimal("10.00"));
        cgcPt = classGradeComponentRepository.save(cgcPt);

        ClassGradeComponent cgcFe = new ClassGradeComponent();
        cgcFe.setClassId(classSe.getClassId());
        cgcFe.setGradeComponentId(fe.getGradeComponentId());
        cgcFe.setWeight(new BigDecimal("40.00"));
        cgcFe = classGradeComponentRepository.save(cgcFe);

        // 5. SCHEDULE
        Schedule schedule = new Schedule();
        schedule.setClassId(classSe.getClassId());
        schedule.setRoomId(de205.getRoomId());
        schedule.setTimeSlotId(slot1.getTimeSlotId());
        schedule.setScheduleDate(LocalDate.now());
        schedule.setStatus("Scheduled");
        schedule.setCreatedBy(1);
        schedule.setCreatedAt(now);
        scheduleRepository.save(schedule);

        // 6. STUDENT GRADES
        StudentGrade sg = new StudentGrade();
        sg.setStudentId(student.getStudentId());
        sg.setClassId(classSe.getClassId());
        sg.setClassGradeComponentId(cgcPt.getClassGradeComponentId());
        sg.setScore(new BigDecimal("8.5"));
        sg.setStatus("Active");
        sg.setEnteredByTeacherId(1);
        sg.setEnteredAt(now);
        studentGradeRepository.save(sg);

        // 7. FEES
        StudentFee fee = new StudentFee();
        fee.setStudentId(student.getStudentId());
        fee.setSemesterId(semester.getSemesterId());
        fee.setFeeTypeId(tuition.getFeeTypeId());
        fee.setAmount(new BigDecimal("12000000"));
        fee.setPaidAmount(new BigDecimal("0"));
        fee.setDueDate(LocalDate.now().plusDays(30));
        fee.setStatus("UNPAID");
        fee.setCreatedBy(1);
        fee.setCreatedAt(now);
        studentFeeRepository.save(fee);

        // 8. NOTIFICATIONS
        Notification notif = new Notification();
        notif.setTitle("Tuition Fee Reminder");
        notif.setContent("Please complete your child's tuition fee payment for Fall 2026.");
        notif.setTargetType("PARENT");
        notif.setIsDeleted(false);
        notif.setSenderId(1); // Admin
        notif.setCreatedAt(now);
        notif = notificationRepository.save(notif);

        NotificationRecipient nr = new NotificationRecipient();
        nr.setNotificationId(notif.getNotificationId());
        nr.setUserId(parentUser.getUserId());
        nr.setIsRead(false);
        notificationRecipientRepository.save(nr);

        System.out.println("✅ Data Seeding Completed Successfully.");
        System.out.println("Parent Login Email: parent@fpt.edu.vn | Pass: 123456");
    }
}
