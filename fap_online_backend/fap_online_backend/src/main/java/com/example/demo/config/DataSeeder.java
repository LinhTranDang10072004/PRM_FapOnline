package com.example.demo.config;

import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final ParentRepository parentRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final StaffRepository staffRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final SemesterRepository semesterRepository;
    private final SubjectRepository subjectRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final ClassStudentRepository classStudentRepository;
    private final ScheduleRepository scheduleRepository;
    private final AttendanceRepository attendanceRepository;
    private final GradeComponentRepository gradeComponentRepository;
    private final ClassGradeComponentRepository classGradeComponentRepository;
    private final StudentGradeRepository studentGradeRepository;
    private final FinalGradeRepository finalGradeRepository;
    private final FeeTypeRepository feeTypeRepository;
    private final StudentFeeRepository studentFeeRepository;
    private final FeePaymentRepository feePaymentRepository;
    private final NotificationRepository notificationRepository;
    private final NotificationRecipientRepository notificationRecipientRepository;
    private final ApplicationTypeRepository applicationTypeRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        seedApplicationTypesIfEmpty();

        if (userRepository.count() > 0) {
            System.out.println("Database already contains users. Skipping full seed.");
            ensureSemesterFilterDemoData();
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        String encodedPassword = passwordEncoder.encode("123456");
        System.out.println("🌱 Starting comprehensive database seeding...");

        // ═══════════════════════════════════════════════════════════════════
        // TIER 0: Master data (no FK dependencies)
        // ═══════════════════════════════════════════════════════════════════

        // --- Roles ---
        Role roleAdmin = saveRole("ADMIN", "Quản trị viên hệ thống", now);
        Role roleTeacher = saveRole("TEACHER", "Giảng viên", now);
        Role roleStudent = saveRole("STUDENT", "Sinh viên", now);
        Role roleParent = saveRole("PARENT", "Phụ huynh", now);
        Role roleStaff = saveRole("STAFF", "Nhân viên", now);

        // --- Fee Types ---
        FeeType tuitionFee = saveFeeType("Học phí", "Học phí theo kỳ");
        FeeType facilityFee = saveFeeType("Phí cơ sở vật chất", "Phí sử dụng phòng lab, thư viện");
        FeeType insuranceFee = saveFeeType("Bảo hiểm y tế", "Bảo hiểm y tế sinh viên");

        // --- Grade Components ---
        GradeComponent gcPT1 = saveGradeComponent("Progress Test 1", "Kiểm tra giữa kỳ lần 1", new BigDecimal("10.00"));
        GradeComponent gcPT2 = saveGradeComponent("Progress Test 2", "Kiểm tra giữa kỳ lần 2", new BigDecimal("10.00"));
        GradeComponent gcAssignment = saveGradeComponent("Assignment", "Bài tập lớn / đồ án", new BigDecimal("20.00"));
        GradeComponent gcParticipation = saveGradeComponent("Participation", "Điểm chuyên cần và thái độ", new BigDecimal("10.00"));
        GradeComponent gcPracticalExam = saveGradeComponent("Practical Exam", "Thi thực hành", new BigDecimal("10.00"));
        GradeComponent gcFinalExam = saveGradeComponent("Final Exam", "Thi cuối kỳ", new BigDecimal("40.00"));

        // --- Rooms ---
        Room de205 = saveRoom("DE-205", "DE-205", 35, "Tầng 2, Tòa Delta");
        Room de301 = saveRoom("DE-301", "DE-301", 40, "Tầng 3, Tòa Delta");
        Room de407 = saveRoom("DE-407", "DE-407", 30, "Tầng 4, Tòa Delta");
        Room al201 = saveRoom("AL-201", "AL-201", 45, "Tầng 2, Tòa Alpha");
        Room be102 = saveRoom("BE-102", "BE-102", 50, "Tầng 1, Tòa Beta (Lab)");

        // --- Time Slots ---
        TimeSlot slot1 = saveTimeSlot("SLOT1", "Slot 1", LocalTime.of(7, 30), LocalTime.of(9, 50));
        TimeSlot slot2 = saveTimeSlot("SLOT2", "Slot 2", LocalTime.of(10, 0), LocalTime.of(12, 20));
        TimeSlot slot3 = saveTimeSlot("SLOT3", "Slot 3", LocalTime.of(12, 50), LocalTime.of(15, 10));
        TimeSlot slot4 = saveTimeSlot("SLOT4", "Slot 4", LocalTime.of(15, 20), LocalTime.of(17, 40));

        // ═══════════════════════════════════════════════════════════════════
        // TIER 1: Users, Subjects, Semesters
        // ═══════════════════════════════════════════════════════════════════

        // --- Semesters (mỗi năm học có 3 kỳ: Fall, Spring, Summer) ---
        // AY 2025-2026
        Semester fall2025 = saveSemester("FA25", "Fall 2025", "2025-2026",
                LocalDate.of(2025, 9, 1), LocalDate.of(2025, 12, 31), "Completed", now);
        Semester spring2026 = saveSemester("SP26", "Spring 2026", "2025-2026",
                LocalDate.of(2026, 1, 5), LocalDate.of(2026, 4, 30), "Completed", now);
        Semester summer2026 = saveSemester("SU26", "Summer 2026", "2025-2026",
                LocalDate.of(2026, 5, 5), LocalDate.of(2026, 8, 31), "Completed", now);
        // AY 2026-2027
        Semester fall2026 = saveSemester("FA26", "Fall 2026", "2026-2027",
                LocalDate.of(2026, 9, 1), LocalDate.of(2026, 12, 31), "Active", now);
        // Status chỉ được phép theo CK_Semesters_Status (vd: Active / Completed)
        Semester spring2027 = saveSemester("SP27", "Spring 2027", "2026-2027",
                LocalDate.of(2027, 1, 5), LocalDate.of(2027, 4, 30), "Active", now);
        Semester summer2027 = saveSemester("SU27", "Summer 2027", "2026-2027",
                LocalDate.of(2027, 5, 5), LocalDate.of(2027, 8, 31), "Active", now);
        System.out.println("   Future semesters prepared: "
                + spring2027.getSemesterCode() + ", " + summer2027.getSemesterCode());

        // --- Subjects ---
        Subject prm392 = saveSubject("PRM392", "Mobile Development", 3, "Phát triển ứng dụng di động với Flutter/Android", now);
        Subject swp391 = saveSubject("SWP391", "Software Development Project", 4, "Dự án phát triển phần mềm theo nhóm", now);
        Subject swd392 = saveSubject("SWD392", "Software Architecture and Design", 3, "Kiến trúc và thiết kế phần mềm", now);
        Subject prj301 = saveSubject("PRJ301", "Java Web Development", 3, "Phát triển web với Java Servlet/JSP", now);
        Subject jpd113 = saveSubject("JPD113", "Japanese Elementary 1", 3, "Tiếng Nhật sơ cấp 1", now);
        Subject mln131 = saveSubject("MLN131", "Philosophy of Marxism-Leninism", 3, "Triết học Mác-Lênin", now);
        Subject iot102 = saveSubject("IOT102", "Internet of Things", 3, "Internet vạn vật", now);

        // --- Users ---
        // Admin
        User adminUser = saveUser("admin", encodedPassword, "Trần Đức Admin", "admin@fpt.edu.vn",
                "0900000000", LocalDate.of(1985, 3, 15), "MALE", "FPT University, Hòa Lạc", now);

        // Teachers
        User teacherUser1 = saveUser("teacher1", encodedPassword, "Nguyễn Văn Hùng", "hungNV@fpt.edu.vn",
                "0901111001", LocalDate.of(1980, 6, 20), "MALE", "Hà Đông, Hà Nội", now);
        User teacherUser2 = saveUser("teacher2", encodedPassword, "Trần Thị Mai", "maiTT@fpt.edu.vn",
                "0901111002", LocalDate.of(1982, 9, 10), "FEMALE", "Cầu Giấy, Hà Nội", now);
        User teacherUser3 = saveUser("teacher3", encodedPassword, "Phạm Đức Anh", "anhPD@fpt.edu.vn",
                "0901111003", LocalDate.of(1978, 11, 5), "MALE", "Thanh Xuân, Hà Nội", now);

        // Staff
        User staffUser1 = saveUser("staff1", encodedPassword, "Lê Thị Hoa", "hoaLT@fpt.edu.vn",
                "0902222001", LocalDate.of(1990, 1, 25), "FEMALE", "Nam Từ Liêm, Hà Nội", now);

        // Parents
        User parentUser1 = saveUser("parent1", encodedPassword, "Nguyễn Thị Lan", "parent1@example.com",
                "0903333001", LocalDate.of(1975, 4, 12), "FEMALE", "123 Phố Huế, Hai Bà Trưng, Hà Nội", now);
        User parentUser2 = saveUser("parent2", encodedPassword, "Trần Văn Bình", "parent2@example.com",
                "0903333002", LocalDate.of(1972, 8, 30), "MALE", "45 Láng Hạ, Đống Đa, Hà Nội", now);
        User parentUser3 = saveUser("parent3", encodedPassword, "Phạm Thị Ngọc", "parent3@example.com",
                "0903333003", LocalDate.of(1978, 12, 18), "FEMALE", "78 Trần Duy Hưng, Cầu Giấy, Hà Nội", now);

        // Students
        User studentUser1 = saveUser("student1", encodedPassword, "Nguyễn Minh Quang", "quangNM@fpt.edu.vn",
                "0904444001", LocalDate.of(2004, 5, 15), "MALE", "123 Phố Huế, Hai Bà Trưng, Hà Nội", now);
        User studentUser2 = saveUser("student2", encodedPassword, "Nguyễn Thị Hương", "huongNT@fpt.edu.vn",
                "0904444002", LocalDate.of(2004, 7, 22), "FEMALE", "123 Phố Huế, Hai Bà Trưng, Hà Nội", now);
        User studentUser3 = saveUser("student3", encodedPassword, "Trần Đức Mạnh", "manhTD@fpt.edu.vn",
                "0904444003", LocalDate.of(2003, 11, 8), "MALE", "45 Láng Hạ, Đống Đa, Hà Nội", now);
        User studentUser4 = saveUser("student4", encodedPassword, "Phạm Thùy Linh", "linhPT@fpt.edu.vn",
                "0904444004", LocalDate.of(2004, 2, 28), "FEMALE", "78 Trần Duy Hưng, Cầu Giấy, Hà Nội", now);
        User studentUser5 = saveUser("student5", encodedPassword, "Lê Hoàng Nam", "namLH@fpt.edu.vn",
                "0904444005", LocalDate.of(2004, 9, 3), "MALE", "90 Kim Mã, Ba Đình, Hà Nội", now);

        // ═══════════════════════════════════════════════════════════════════
        // TIER 2: Profiles & Roles
        // ═══════════════════════════════════════════════════════════════════

        // Assign roles
        saveUserRole(adminUser.getUserId(), roleAdmin.getRoleId(), now);
        saveUserRole(teacherUser1.getUserId(), roleTeacher.getRoleId(), now);
        saveUserRole(teacherUser2.getUserId(), roleTeacher.getRoleId(), now);
        saveUserRole(teacherUser3.getUserId(), roleTeacher.getRoleId(), now);
        saveUserRole(staffUser1.getUserId(), roleStaff.getRoleId(), now);
        saveUserRole(parentUser1.getUserId(), roleParent.getRoleId(), now);
        saveUserRole(parentUser2.getUserId(), roleParent.getRoleId(), now);
        saveUserRole(parentUser3.getUserId(), roleParent.getRoleId(), now);
        saveUserRole(studentUser1.getUserId(), roleStudent.getRoleId(), now);
        saveUserRole(studentUser2.getUserId(), roleStudent.getRoleId(), now);
        saveUserRole(studentUser3.getUserId(), roleStudent.getRoleId(), now);
        saveUserRole(studentUser4.getUserId(), roleStudent.getRoleId(), now);
        saveUserRole(studentUser5.getUserId(), roleStudent.getRoleId(), now);

        // Teacher profiles
        Teacher teacher1 = saveTeacher(teacherUser1.getUserId(), "TC001", "Công nghệ phần mềm", "Java/Mobile Development", now);
        Teacher teacher2 = saveTeacher(teacherUser2.getUserId(), "TC002", "Công nghệ phần mềm", "Software Architecture", now);
        Teacher teacher3 = saveTeacher(teacherUser3.getUserId(), "TC003", "Khoa học máy tính", "IoT/Embedded Systems", now);

        // Staff profile
        saveStaff(staffUser1.getUserId(), "ST001", "Phòng Đào tạo", now);

        // Parent profiles
        Parent parent1 = saveParent(parentUser1.getUserId(), "PH001", "Giáo viên", now);
        Parent parent2 = saveParent(parentUser2.getUserId(), "PH002", "Kỹ sư xây dựng", now);
        Parent parent3 = saveParent(parentUser3.getUserId(), "PH003", "Bác sĩ", now);

        // Student profiles
        Student student1 = saveStudent(studentUser1.getUserId(), "SE18001", "Software Engineering", 2022, now);
        Student student2 = saveStudent(studentUser2.getUserId(), "SE18002", "Software Engineering", 2022, now);
        Student student3 = saveStudent(studentUser3.getUserId(), "SE17015", "Software Engineering", 2021, now);
        Student student4 = saveStudent(studentUser4.getUserId(), "SE18010", "Software Engineering", 2022, now);
        Student student5 = saveStudent(studentUser5.getUserId(), "SE18025", "Software Engineering", 2022, now);

        // ═══════════════════════════════════════════════════════════════════
        // TIER 3: Parent-Student relationships, Classes
        // ═══════════════════════════════════════════════════════════════════

        // Parent 1 (Nguyễn Thị Lan) → Student 1 (Quang) & Student 2 (Hương) — siblings
        saveParentStudent(parent1.getParentId(), student1.getStudentId(), "Mẹ", true, now);
        saveParentStudent(parent1.getParentId(), student2.getStudentId(), "Mẹ", true, now);

        // Parent 2 (Trần Văn Bình) → Student 3 (Mạnh)
        saveParentStudent(parent2.getParentId(), student3.getStudentId(), "Bố", true, now);

        // Parent 3 (Phạm Thị Ngọc) → Student 4 (Linh)
        saveParentStudent(parent3.getParentId(), student4.getStudentId(), "Mẹ", true, now);

        // --- Fall 2026 Classes ---
        SchoolClass classPRM_A = saveClass("PRM392-A", "PRM392 - Nhóm A", prm392.getSubjectId(),
                fall2026.getSemesterId(), teacher1.getTeacherId(), 35, now);
        SchoolClass classSWP_A = saveClass("SWP391-A", "SWP391 - Nhóm A", swp391.getSubjectId(),
                fall2026.getSemesterId(), teacher2.getTeacherId(), 30, now);
        SchoolClass classSWD_A = saveClass("SWD392-A", "SWD392 - Nhóm A", swd392.getSubjectId(),
                fall2026.getSemesterId(), teacher2.getTeacherId(), 35, now);
        SchoolClass classPRJ_B = saveClass("PRJ301-B", "PRJ301 - Nhóm B", prj301.getSubjectId(),
                fall2026.getSemesterId(), teacher1.getTeacherId(), 40, now);
        SchoolClass classIOT_A = saveClass("IOT102-A", "IOT102 - Nhóm A", iot102.getSubjectId(),
                fall2026.getSemesterId(), teacher3.getTeacherId(), 30, now);
        SchoolClass classJPD_A = saveClass("JPD113-A", "JPD113 - Nhóm A", jpd113.getSubjectId(),
                fall2026.getSemesterId(), null, 40, now);
        SchoolClass classMLN_A = saveClass("MLN131-A", "MLN131 - Nhóm A", mln131.getSubjectId(),
                fall2026.getSemesterId(), null, 45, now);

        // ═══════════════════════════════════════════════════════════════════
        // TIER 4: Class enrollment, Grade components, Schedules, Fees
        // ═══════════════════════════════════════════════════════════════════

        // Enroll students into classes
        // Student 1 (Quang): PRM392, SWP391, MLN131
        saveClassStudent(classPRM_A.getClassId(), student1.getStudentId(), now);
        saveClassStudent(classSWP_A.getClassId(), student1.getStudentId(), now);
        saveClassStudent(classMLN_A.getClassId(), student1.getStudentId(), now);

        // Student 2 (Hương): PRM392, SWD392, JPD113
        saveClassStudent(classPRM_A.getClassId(), student2.getStudentId(), now);
        saveClassStudent(classSWD_A.getClassId(), student2.getStudentId(), now);
        saveClassStudent(classJPD_A.getClassId(), student2.getStudentId(), now);

        // Student 3 (Mạnh): SWP391, PRJ301, IOT102
        saveClassStudent(classSWP_A.getClassId(), student3.getStudentId(), now);
        saveClassStudent(classPRJ_B.getClassId(), student3.getStudentId(), now);
        saveClassStudent(classIOT_A.getClassId(), student3.getStudentId(), now);

        // Student 4 (Linh): PRM392, SWD392, SWP391
        saveClassStudent(classPRM_A.getClassId(), student4.getStudentId(), now);
        saveClassStudent(classSWD_A.getClassId(), student4.getStudentId(), now);
        saveClassStudent(classSWP_A.getClassId(), student4.getStudentId(), now);

        // Student 5 (Nam): PRJ301, IOT102, MLN131
        saveClassStudent(classPRJ_B.getClassId(), student5.getStudentId(), now);
        saveClassStudent(classIOT_A.getClassId(), student5.getStudentId(), now);
        saveClassStudent(classMLN_A.getClassId(), student5.getStudentId(), now);

        // --- Class Grade Components for PRM392 ---
        ClassGradeComponent prm_pt1 = saveClassGradeComponent(classPRM_A.getClassId(), gcPT1.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent prm_pt2 = saveClassGradeComponent(classPRM_A.getClassId(), gcPT2.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent prm_assign = saveClassGradeComponent(classPRM_A.getClassId(), gcAssignment.getGradeComponentId(), new BigDecimal("20.00"));
        ClassGradeComponent prm_part = saveClassGradeComponent(classPRM_A.getClassId(), gcParticipation.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent prm_pe = saveClassGradeComponent(classPRM_A.getClassId(), gcPracticalExam.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent prm_fe = saveClassGradeComponent(classPRM_A.getClassId(), gcFinalExam.getGradeComponentId(), new BigDecimal("40.00"));

        // --- Class Grade Components for SWP391 ---
        ClassGradeComponent swp_pt1 = saveClassGradeComponent(classSWP_A.getClassId(), gcPT1.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent swp_assign = saveClassGradeComponent(classSWP_A.getClassId(), gcAssignment.getGradeComponentId(), new BigDecimal("30.00"));
        ClassGradeComponent swp_part = saveClassGradeComponent(classSWP_A.getClassId(), gcParticipation.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent swp_fe = saveClassGradeComponent(classSWP_A.getClassId(), gcFinalExam.getGradeComponentId(), new BigDecimal("50.00"));

        // --- Class Grade Components for SWD392 ---
        ClassGradeComponent swd_pt1 = saveClassGradeComponent(classSWD_A.getClassId(), gcPT1.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent swd_pt2 = saveClassGradeComponent(classSWD_A.getClassId(), gcPT2.getGradeComponentId(), new BigDecimal("10.00"));
        ClassGradeComponent swd_assign = saveClassGradeComponent(classSWD_A.getClassId(), gcAssignment.getGradeComponentId(), new BigDecimal("20.00"));
        ClassGradeComponent swd_fe = saveClassGradeComponent(classSWD_A.getClassId(), gcFinalExam.getGradeComponentId(), new BigDecimal("60.00"));

        // --- Schedules: Current Week for Testing ---
        // Use the real current week so the dashboard always has data today.
        LocalDate currentWeekMonday = LocalDate.now().minusDays(LocalDate.now().getDayOfWeek().getValue() - 1);
        
        // Current week schedules
        Schedule currentWeekPRM_Mon = saveSchedule(classPRM_A.getClassId(), de205.getRoomId(), slot1.getTimeSlotId(),
                currentWeekMonday, adminUser.getUserId(), now); // Monday
        Schedule currentWeekPRM_Wed = saveSchedule(classPRM_A.getClassId(), de205.getRoomId(), slot1.getTimeSlotId(),
                currentWeekMonday.plusDays(2), adminUser.getUserId(), now); // Wednesday
        
        Schedule currentWeekSWP_Tue = saveSchedule(classSWP_A.getClassId(), de301.getRoomId(), slot2.getTimeSlotId(),
                currentWeekMonday.plusDays(1), adminUser.getUserId(), now); // Tuesday
        Schedule currentWeekSWP_Thu = saveSchedule(classSWP_A.getClassId(), de301.getRoomId(), slot2.getTimeSlotId(),
                currentWeekMonday.plusDays(3), adminUser.getUserId(), now); // Thursday
        
        Schedule currentWeekSWD_Mon = saveSchedule(classSWD_A.getClassId(), de407.getRoomId(), slot3.getTimeSlotId(),
                currentWeekMonday, adminUser.getUserId(), now); // Monday
        Schedule currentWeekSWD_Fri = saveSchedule(classSWD_A.getClassId(), de407.getRoomId(), slot3.getTimeSlotId(),
                currentWeekMonday.plusDays(4), adminUser.getUserId(), now); // Friday

        // Each seeded parent account has at least one class shown on the
        // dashboard for the current day, regardless of which day it is seeded.
        Schedule dashboardTodayPRM = saveSchedule(classPRM_A.getClassId(), de205.getRoomId(), slot1.getTimeSlotId(),
                LocalDate.now(), adminUser.getUserId(), now);
        Schedule dashboardTodaySWP = saveSchedule(classSWP_A.getClassId(), de301.getRoomId(), slot2.getTimeSlotId(),
                LocalDate.now(), adminUser.getUserId(), now);
        
        // Add current week attendance (for testing date range picker)
        saveAttendance(currentWeekPRM_Mon.getScheduleId(), student1.getStudentId(), "PRESENT", teacher1.getTeacherId(), now);
        saveAttendance(currentWeekPRM_Wed.getScheduleId(), student1.getStudentId(), "PRESENT", teacher1.getTeacherId(), now);
        saveAttendance(currentWeekSWP_Tue.getScheduleId(), student1.getStudentId(), "PRESENT", teacher2.getTeacherId(), now);
        saveAttendance(currentWeekSWP_Thu.getScheduleId(), student1.getStudentId(), "PRESENT", teacher2.getTeacherId(), now);
        saveAttendance(dashboardTodayPRM.getScheduleId(), student1.getStudentId(), "PRESENT", teacher1.getTeacherId(), now);
        saveAttendance(dashboardTodaySWP.getScheduleId(), student1.getStudentId(), "PRESENT", teacher2.getTeacherId(), now);

        // --- Schedules: PRM392 Mon & Wed Slot 1 (September 2026) ---
        LocalDate weekStart = LocalDate.of(2026, 9, 7); // First Monday of semester
        Schedule[] prmSchedules = new Schedule[8];
        for (int w = 0; w < 4; w++) {
            prmSchedules[w * 2] = saveSchedule(classPRM_A.getClassId(), de205.getRoomId(), slot1.getTimeSlotId(),
                    weekStart.plusWeeks(w), adminUser.getUserId(), now); // Monday
            prmSchedules[w * 2 + 1] = saveSchedule(classPRM_A.getClassId(), de205.getRoomId(), slot1.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(2), adminUser.getUserId(), now); // Wednesday
        }

        // --- Schedules: SWP391 Tue & Thu Slot 2 ---
        Schedule[] swpSchedules = new Schedule[8];
        for (int w = 0; w < 4; w++) {
            swpSchedules[w * 2] = saveSchedule(classSWP_A.getClassId(), de301.getRoomId(), slot2.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(1), adminUser.getUserId(), now); // Tuesday
            swpSchedules[w * 2 + 1] = saveSchedule(classSWP_A.getClassId(), de301.getRoomId(), slot2.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(3), adminUser.getUserId(), now); // Thursday
        }

        // --- Schedules: SWD392 Mon & Fri Slot 3 ---
        Schedule[] swdSchedules = new Schedule[8];
        for (int w = 0; w < 4; w++) {
            swdSchedules[w * 2] = saveSchedule(classSWD_A.getClassId(), de407.getRoomId(), slot3.getTimeSlotId(),
                    weekStart.plusWeeks(w), adminUser.getUserId(), now); // Monday
            swdSchedules[w * 2 + 1] = saveSchedule(classSWD_A.getClassId(), de407.getRoomId(), slot3.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(4), adminUser.getUserId(), now); // Friday
        }

        // --- Schedules: PRJ301 Tue & Thu Slot 1 ---
        Schedule[] prjSchedules = new Schedule[6];
        for (int w = 0; w < 3; w++) {
            prjSchedules[w * 2] = saveSchedule(classPRJ_B.getClassId(), al201.getRoomId(), slot1.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(1), adminUser.getUserId(), now);
            prjSchedules[w * 2 + 1] = saveSchedule(classPRJ_B.getClassId(), al201.getRoomId(), slot1.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(3), adminUser.getUserId(), now);
        }

        // --- Schedules: IOT102 Wed Slot 3 & Fri Slot 2 ---
        Schedule[] iotSchedules = new Schedule[6];
        for (int w = 0; w < 3; w++) {
            iotSchedules[w * 2] = saveSchedule(classIOT_A.getClassId(), be102.getRoomId(), slot3.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(2), adminUser.getUserId(), now);
            iotSchedules[w * 2 + 1] = saveSchedule(classIOT_A.getClassId(), be102.getRoomId(), slot2.getTimeSlotId(),
                    weekStart.plusWeeks(w).plusDays(4), adminUser.getUserId(), now);
        }

        // ═══════════════════════════════════════════════════════════════════
        // TIER 5: Attendance, Grades, Fees, Notifications
        // ═══════════════════════════════════════════════════════════════════

        // --- Attendance for PRM392 (Student 1, 2, 4) ---
        // Student 1 (Quang): mostly present, 1 late
        String[] s1PrmStatus = {"PRESENT", "PRESENT", "LATE", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "PRESENT"};
        for (int i = 0; i < prmSchedules.length; i++) {
            saveAttendance(prmSchedules[i].getScheduleId(), student1.getStudentId(), s1PrmStatus[i],
                    teacher1.getTeacherId(), now.plusHours(i));
        }
        // Student 2 (Hương): 1 absent, 1 excused
        String[] s2PrmStatus = {"PRESENT", "ABSENT", "PRESENT", "PRESENT", "EXCUSED", "PRESENT", "PRESENT", "PRESENT"};
        for (int i = 0; i < prmSchedules.length; i++) {
            saveAttendance(prmSchedules[i].getScheduleId(), student2.getStudentId(), s2PrmStatus[i],
                    teacher1.getTeacherId(), now.plusHours(i));
        }
        // Student 4 (Linh): good attendance
        String[] s4PrmStatus = {"PRESENT", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "LATE", "PRESENT", "PRESENT"};
        for (int i = 0; i < prmSchedules.length; i++) {
            saveAttendance(prmSchedules[i].getScheduleId(), student4.getStudentId(), s4PrmStatus[i],
                    teacher1.getTeacherId(), now.plusHours(i));
        }

        // --- Attendance for SWP391 (Student 1, 3, 4) ---
        String[] s1SwpStatus = {"PRESENT", "PRESENT", "PRESENT", "LATE", "PRESENT", "PRESENT", "ABSENT", "PRESENT"};
        for (int i = 0; i < swpSchedules.length; i++) {
            saveAttendance(swpSchedules[i].getScheduleId(), student1.getStudentId(), s1SwpStatus[i],
                    teacher2.getTeacherId(), now.plusHours(i));
        }
        String[] s3SwpStatus = {"PRESENT", "ABSENT", "PRESENT", "PRESENT", "ABSENT", "PRESENT", "LATE", "PRESENT"};
        for (int i = 0; i < swpSchedules.length; i++) {
            saveAttendance(swpSchedules[i].getScheduleId(), student3.getStudentId(), s3SwpStatus[i],
                    teacher2.getTeacherId(), now.plusHours(i));
        }
        String[] s4SwpStatus = {"PRESENT", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "LATE"};
        for (int i = 0; i < swpSchedules.length; i++) {
            saveAttendance(swpSchedules[i].getScheduleId(), student4.getStudentId(), s4SwpStatus[i],
                    teacher2.getTeacherId(), now.plusHours(i));
        }

        // --- Attendance for SWD392 (Student 2, 4) ---
        String[] s2SwdStatus = {"PRESENT", "PRESENT", "LATE", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "ABSENT"};
        for (int i = 0; i < swdSchedules.length; i++) {
            saveAttendance(swdSchedules[i].getScheduleId(), student2.getStudentId(), s2SwdStatus[i],
                    teacher2.getTeacherId(), now.plusHours(i));
        }
        String[] s4SwdStatus = {"PRESENT", "PRESENT", "PRESENT", "PRESENT", "LATE", "PRESENT", "PRESENT", "PRESENT"};
        for (int i = 0; i < swdSchedules.length; i++) {
            saveAttendance(swdSchedules[i].getScheduleId(), student4.getStudentId(), s4SwdStatus[i],
                    teacher2.getTeacherId(), now.plusHours(i));
        }

        // --- Student Grades for PRM392 ---
        // Student 1 (Quang) - Good student
        saveStudentGrade(student1.getStudentId(), classPRM_A.getClassId(), prm_pt1.getClassGradeComponentId(), new BigDecimal("8.5"), teacher1.getTeacherId(), now);
        saveStudentGrade(student1.getStudentId(), classPRM_A.getClassId(), prm_pt2.getClassGradeComponentId(), new BigDecimal("9.0"), teacher1.getTeacherId(), now);
        saveStudentGrade(student1.getStudentId(), classPRM_A.getClassId(), prm_assign.getClassGradeComponentId(), new BigDecimal("8.0"), teacher1.getTeacherId(), now);
        saveStudentGrade(student1.getStudentId(), classPRM_A.getClassId(), prm_part.getClassGradeComponentId(), new BigDecimal("9.0"), teacher1.getTeacherId(), now);
        // PE and FE not graded yet

        // Student 2 (Hương) - Average student
        saveStudentGrade(student2.getStudentId(), classPRM_A.getClassId(), prm_pt1.getClassGradeComponentId(), new BigDecimal("6.5"), teacher1.getTeacherId(), now);
        saveStudentGrade(student2.getStudentId(), classPRM_A.getClassId(), prm_pt2.getClassGradeComponentId(), new BigDecimal("7.0"), teacher1.getTeacherId(), now);
        saveStudentGrade(student2.getStudentId(), classPRM_A.getClassId(), prm_assign.getClassGradeComponentId(), new BigDecimal("7.5"), teacher1.getTeacherId(), now);
        saveStudentGrade(student2.getStudentId(), classPRM_A.getClassId(), prm_part.getClassGradeComponentId(), new BigDecimal("6.0"), teacher1.getTeacherId(), now);

        // Student 4 (Linh) - Excellent student
        saveStudentGrade(student4.getStudentId(), classPRM_A.getClassId(), prm_pt1.getClassGradeComponentId(), new BigDecimal("9.5"), teacher1.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classPRM_A.getClassId(), prm_pt2.getClassGradeComponentId(), new BigDecimal("9.0"), teacher1.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classPRM_A.getClassId(), prm_assign.getClassGradeComponentId(), new BigDecimal("9.5"), teacher1.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classPRM_A.getClassId(), prm_part.getClassGradeComponentId(), new BigDecimal("10.0"), teacher1.getTeacherId(), now);

        // --- Student Grades for SWP391 ---
        saveStudentGrade(student1.getStudentId(), classSWP_A.getClassId(), swp_pt1.getClassGradeComponentId(), new BigDecimal("7.5"), teacher2.getTeacherId(), now);
        saveStudentGrade(student1.getStudentId(), classSWP_A.getClassId(), swp_assign.getClassGradeComponentId(), new BigDecimal("8.0"), teacher2.getTeacherId(), now);
        saveStudentGrade(student1.getStudentId(), classSWP_A.getClassId(), swp_part.getClassGradeComponentId(), new BigDecimal("8.5"), teacher2.getTeacherId(), now);

        saveStudentGrade(student3.getStudentId(), classSWP_A.getClassId(), swp_pt1.getClassGradeComponentId(), new BigDecimal("5.0"), teacher2.getTeacherId(), now);
        saveStudentGrade(student3.getStudentId(), classSWP_A.getClassId(), swp_assign.getClassGradeComponentId(), new BigDecimal("6.5"), teacher2.getTeacherId(), now);
        saveStudentGrade(student3.getStudentId(), classSWP_A.getClassId(), swp_part.getClassGradeComponentId(), new BigDecimal("4.0"), teacher2.getTeacherId(), now);

        saveStudentGrade(student4.getStudentId(), classSWP_A.getClassId(), swp_pt1.getClassGradeComponentId(), new BigDecimal("9.0"), teacher2.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classSWP_A.getClassId(), swp_assign.getClassGradeComponentId(), new BigDecimal("8.5"), teacher2.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classSWP_A.getClassId(), swp_part.getClassGradeComponentId(), new BigDecimal("9.5"), teacher2.getTeacherId(), now);

        // --- Student Grades for SWD392 ---
        saveStudentGrade(student2.getStudentId(), classSWD_A.getClassId(), swd_pt1.getClassGradeComponentId(), new BigDecimal("7.0"), teacher2.getTeacherId(), now);
        saveStudentGrade(student2.getStudentId(), classSWD_A.getClassId(), swd_pt2.getClassGradeComponentId(), new BigDecimal("6.5"), teacher2.getTeacherId(), now);
        saveStudentGrade(student2.getStudentId(), classSWD_A.getClassId(), swd_assign.getClassGradeComponentId(), new BigDecimal("7.0"), teacher2.getTeacherId(), now);

        saveStudentGrade(student4.getStudentId(), classSWD_A.getClassId(), swd_pt1.getClassGradeComponentId(), new BigDecimal("8.5"), teacher2.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classSWD_A.getClassId(), swd_pt2.getClassGradeComponentId(), new BigDecimal("9.0"), teacher2.getTeacherId(), now);
        saveStudentGrade(student4.getStudentId(), classSWD_A.getClassId(), swd_assign.getClassGradeComponentId(), new BigDecimal("8.0"), teacher2.getTeacherId(), now);

        // --- Fall 2025 Classes (AY 2025-2026) ---
        SchoolClass classPRJ_Fall25 = saveClass("PRJ301-FA25", "PRJ301 - Fall 2025", prj301.getSubjectId(),
                fall2025.getSemesterId(), teacher1.getTeacherId(), 40, now);
        classPRJ_Fall25.setStatus("Completed");
        schoolClassRepository.save(classPRJ_Fall25);
        SchoolClass classSWD_Fall25 = saveClass("SWD392-FA25", "SWD392 - Fall 2025", swd392.getSubjectId(),
                fall2025.getSemesterId(), teacher2.getTeacherId(), 35, now);
        classSWD_Fall25.setStatus("Completed");
        schoolClassRepository.save(classSWD_Fall25);
        SchoolClass classJPD_Fall25 = saveClass("JPD113-FA25", "JPD113 - Fall 2025", jpd113.getSubjectId(),
                fall2025.getSemesterId(), teacher3.getTeacherId(), 40, now);
        classJPD_Fall25.setStatus("Completed");
        schoolClassRepository.save(classJPD_Fall25);

        // Fall 2025 enrollments: 4 students
        saveClassStudent(classPRJ_Fall25.getClassId(), student1.getStudentId(), now.minusMonths(10));
        saveClassStudent(classPRJ_Fall25.getClassId(), student2.getStudentId(), now.minusMonths(10));
        saveClassStudent(classPRJ_Fall25.getClassId(), student3.getStudentId(), now.minusMonths(10));
        saveClassStudent(classSWD_Fall25.getClassId(), student1.getStudentId(), now.minusMonths(10));
        saveClassStudent(classSWD_Fall25.getClassId(), student4.getStudentId(), now.minusMonths(10));
        saveClassStudent(classJPD_Fall25.getClassId(), student2.getStudentId(), now.minusMonths(10));
        saveClassStudent(classJPD_Fall25.getClassId(), student4.getStudentId(), now.minusMonths(10));

        // --- Spring 2026 Classes (AY 2025-2026) ---
        SchoolClass classPRM_Spring = saveClass("PRM392-SP", "PRM392 - Spring 2026", prm392.getSubjectId(),
                spring2026.getSemesterId(), teacher1.getTeacherId(), 35, now);
        classPRM_Spring.setStatus("Completed");
        schoolClassRepository.save(classPRM_Spring);
        SchoolClass classIOT_Spring = saveClass("IOT102-SP", "IOT102 - Spring 2026", iot102.getSubjectId(),
                spring2026.getSemesterId(), teacher3.getTeacherId(), 30, now);
        classIOT_Spring.setStatus("Completed");
        schoolClassRepository.save(classIOT_Spring);
        SchoolClass classMLN_Spring = saveClass("MLN131-SP", "MLN131 - Spring 2026", mln131.getSubjectId(),
                spring2026.getSemesterId(), teacher2.getTeacherId(), 45, now);
        classMLN_Spring.setStatus("Completed");
        schoolClassRepository.save(classMLN_Spring);

        // Spring 2026 enrollments: 3 students
        saveClassStudent(classPRM_Spring.getClassId(), student1.getStudentId(), now.minusMonths(6));
        saveClassStudent(classPRM_Spring.getClassId(), student3.getStudentId(), now.minusMonths(6));
        saveClassStudent(classIOT_Spring.getClassId(), student1.getStudentId(), now.minusMonths(6));
        saveClassStudent(classIOT_Spring.getClassId(), student5.getStudentId(), now.minusMonths(6));
        saveClassStudent(classMLN_Spring.getClassId(), student3.getStudentId(), now.minusMonths(6));
        saveClassStudent(classMLN_Spring.getClassId(), student5.getStudentId(), now.minusMonths(6));

        saveFinalGrade(classPRM_Spring.getClassId(), student1.getStudentId(), new BigDecimal("8.2"), "B+", "PASS", now.minusMonths(3), adminUser.getUserId());
        saveFinalGrade(classPRM_Spring.getClassId(), student3.getStudentId(), new BigDecimal("4.8"), "D", "FAIL", now.minusMonths(3), adminUser.getUserId());

        // --- Summer 2026 Classes (AY 2025-2026) ---
        SchoolClass classSWP_Summer = saveClass("SWP391-SU", "SWP391 - Summer 2026", swp391.getSubjectId(),
                summer2026.getSemesterId(), teacher2.getTeacherId(), 30, now);
        classSWP_Summer.setStatus("Completed");
        schoolClassRepository.save(classSWP_Summer);
        SchoolClass classPRM_Summer = saveClass("PRM392-SU", "PRM392 - Summer 2026", prm392.getSubjectId(),
                summer2026.getSemesterId(), teacher1.getTeacherId(), 35, now);
        classPRM_Summer.setStatus("Completed");
        schoolClassRepository.save(classPRM_Summer);

        // Summer 2026 enrollments: 2 students
        saveClassStudent(classSWP_Summer.getClassId(), student2.getStudentId(), now.minusMonths(3));
        saveClassStudent(classSWP_Summer.getClassId(), student4.getStudentId(), now.minusMonths(3));
        saveClassStudent(classPRM_Summer.getClassId(), student2.getStudentId(), now.minusMonths(3));
        saveClassStudent(classPRM_Summer.getClassId(), student5.getStudentId(), now.minusMonths(3));

        // Spring/Summer 2027 chưa mở lớp — dùng để test filter năm 2026-2027

        // --- Student Fees ---
        // Fall 2026 tuition
        StudentFee fee1_tuition = saveStudentFee(student1.getStudentId(), fall2026.getSemesterId(), tuitionFee.getFeeTypeId(),
                new BigDecimal("14500000"), new BigDecimal("14500000"), LocalDate.of(2026, 9, 15), "PAID", adminUser.getUserId(), now);
        StudentFee fee1_facility = saveStudentFee(student1.getStudentId(), fall2026.getSemesterId(), facilityFee.getFeeTypeId(),
                new BigDecimal("1500000"), new BigDecimal("1500000"), LocalDate.of(2026, 9, 15), "PAID", adminUser.getUserId(), now);
        StudentFee fee1_insurance = saveStudentFee(student1.getStudentId(), fall2026.getSemesterId(), insuranceFee.getFeeTypeId(),
                new BigDecimal("450000"), new BigDecimal("0"), LocalDate.of(2026, 10, 30), "UNPAID", adminUser.getUserId(), now);

        StudentFee fee2_tuition = saveStudentFee(student2.getStudentId(), fall2026.getSemesterId(), tuitionFee.getFeeTypeId(),
                new BigDecimal("14500000"), new BigDecimal("7250000"), LocalDate.of(2026, 9, 15), "PARTIAL", adminUser.getUserId(), now);
        StudentFee fee2_facility = saveStudentFee(student2.getStudentId(), fall2026.getSemesterId(), facilityFee.getFeeTypeId(),
                new BigDecimal("1500000"), new BigDecimal("0"), LocalDate.of(2026, 9, 15), "UNPAID", adminUser.getUserId(), now);
        StudentFee fee2_insurance = saveStudentFee(student2.getStudentId(), fall2026.getSemesterId(), insuranceFee.getFeeTypeId(),
                new BigDecimal("450000"), new BigDecimal("450000"), LocalDate.of(2026, 10, 30), "PAID", adminUser.getUserId(), now);

        StudentFee fee3_tuition = saveStudentFee(student3.getStudentId(), fall2026.getSemesterId(), tuitionFee.getFeeTypeId(),
                new BigDecimal("14500000"), new BigDecimal("0"), LocalDate.of(2026, 9, 15), "OVERDUE", adminUser.getUserId(), now);
        StudentFee fee3_facility = saveStudentFee(student3.getStudentId(), fall2026.getSemesterId(), facilityFee.getFeeTypeId(),
                new BigDecimal("1500000"), new BigDecimal("1500000"), LocalDate.of(2026, 9, 15), "PAID", adminUser.getUserId(), now);

        StudentFee fee4_tuition = saveStudentFee(student4.getStudentId(), fall2026.getSemesterId(), tuitionFee.getFeeTypeId(),
                new BigDecimal("14500000"), new BigDecimal("14500000"), LocalDate.of(2026, 9, 15), "PAID", adminUser.getUserId(), now);
        StudentFee fee4_facility = saveStudentFee(student4.getStudentId(), fall2026.getSemesterId(), facilityFee.getFeeTypeId(),
                new BigDecimal("1500000"), new BigDecimal("1500000"), LocalDate.of(2026, 9, 15), "PAID", adminUser.getUserId(), now);
        StudentFee fee4_insurance = saveStudentFee(student4.getStudentId(), fall2026.getSemesterId(), insuranceFee.getFeeTypeId(),
                new BigDecimal("450000"), new BigDecimal("450000"), LocalDate.of(2026, 10, 30), "PAID", adminUser.getUserId(), now);

        StudentFee fee5_tuition = saveStudentFee(student5.getStudentId(), fall2026.getSemesterId(), tuitionFee.getFeeTypeId(),
                new BigDecimal("14500000"), new BigDecimal("5000000"), LocalDate.of(2026, 9, 15), "PARTIAL", adminUser.getUserId(), now);

        // --- Fee Payments ---
        saveFeePayment(fee1_tuition.getStudentFeeId(), new BigDecimal("14500000"), now.minusDays(20), "BANK_TRANSFER", "VCB20260820001", staffUser1.getUserId());
        saveFeePayment(fee1_facility.getStudentFeeId(), new BigDecimal("1500000"), now.minusDays(20), "BANK_TRANSFER", "VCB20260820002", staffUser1.getUserId());
        saveFeePayment(fee2_tuition.getStudentFeeId(), new BigDecimal("7250000"), now.minusDays(15), "BANK_TRANSFER", "VCB20260825001", staffUser1.getUserId());
        saveFeePayment(fee2_insurance.getStudentFeeId(), new BigDecimal("450000"), now.minusDays(10), "CASH", null, staffUser1.getUserId());
        saveFeePayment(fee3_facility.getStudentFeeId(), new BigDecimal("1500000"), now.minusDays(18), "MOMO", "MOMO20260822001", staffUser1.getUserId());
        saveFeePayment(fee4_tuition.getStudentFeeId(), new BigDecimal("14500000"), now.minusDays(25), "BANK_TRANSFER", "TCB20260815001", staffUser1.getUserId());
        saveFeePayment(fee4_facility.getStudentFeeId(), new BigDecimal("1500000"), now.minusDays(25), "BANK_TRANSFER", "TCB20260815002", staffUser1.getUserId());
        saveFeePayment(fee4_insurance.getStudentFeeId(), new BigDecimal("450000"), now.minusDays(5), "VNPAY", "VNPAY20260905001", staffUser1.getUserId());
        saveFeePayment(fee5_tuition.getStudentFeeId(), new BigDecimal("5000000"), now.minusDays(12), "BANK_TRANSFER", "MB20260828001", staffUser1.getUserId());

        // ═══════════════════════════════════════════════════════════════════
        // TIER 6: Notifications
        // ═══════════════════════════════════════════════════════════════════

        // Notification 1: Tuition reminder (for all parents)
        Notification n1 = saveNotification("Nhắc nhở đóng học phí kỳ Fall 2026",
                "Kính gửi Phụ huynh,\n\nNhà trường xin thông báo hạn đóng học phí kỳ Fall 2026 là ngày 15/09/2026. "
                + "Quý phụ huynh vui lòng kiểm tra và hoàn tất việc đóng học phí đúng hạn.\n\nTrân trọng,\nPhòng Tài chính",
                adminUser.getUserId(), "PARENT", now.minusDays(30));
        saveNotificationRecipient(n1.getNotificationId(), parentUser1.getUserId(), true, now.minusDays(28));
        saveNotificationRecipient(n1.getNotificationId(), parentUser2.getUserId(), false, null);
        saveNotificationRecipient(n1.getNotificationId(), parentUser3.getUserId(), true, now.minusDays(29));

        // Notification 2: Schedule change
        Notification n2 = saveNotification("Thay đổi lịch học môn PRM392",
                "Thông báo: Lịch học môn PRM392 ngày 14/09/2026 sẽ được chuyển sang phòng DE-301 do phòng DE-205 đang bảo trì. "
                + "Thời gian học không thay đổi (Slot 1: 07:30 - 09:50).\n\nMọi thắc mắc xin liên hệ Phòng Đào tạo.",
                staffUser1.getUserId(), "PARENT", now.minusDays(20));
        saveNotificationRecipient(n2.getNotificationId(), parentUser1.getUserId(), true, now.minusDays(19));
        saveNotificationRecipient(n2.getNotificationId(), parentUser3.getUserId(), true, now.minusDays(18));

        // Notification 3: Midterm results
        Notification n3 = saveNotification("Kết quả kiểm tra giữa kỳ",
                "Kính gửi Phụ huynh,\n\nKết quả kiểm tra giữa kỳ (Progress Test 1) đã được cập nhật trên hệ thống. "
                + "Quý phụ huynh có thể xem điểm chi tiết trong mục Bảng điểm.\n\nNếu có thắc mắc, vui lòng liên hệ giảng viên phụ trách.",
                adminUser.getUserId(), "PARENT", now.minusDays(10));
        saveNotificationRecipient(n3.getNotificationId(), parentUser1.getUserId(), true, now.minusDays(9));
        saveNotificationRecipient(n3.getNotificationId(), parentUser2.getUserId(), true, now.minusDays(8));
        saveNotificationRecipient(n3.getNotificationId(), parentUser3.getUserId(), false, null);

        // Notification 4: Absence warning
        Notification n4 = saveNotification("Cảnh báo nghỉ học",
                "Kính gửi Phụ huynh,\n\nHệ thống ghi nhận con em bạn đã nghỉ 2 buổi trong tháng qua ở môn SWP391. "
                + "Theo quy định, sinh viên nghỉ quá 20% số buổi sẽ bị cấm thi.\n\nĐề nghị phụ huynh nhắc nhở con em đi học đầy đủ.",
                teacher2.getUserId(), "PARENT", now.minusDays(5));
        saveNotificationRecipient(n4.getNotificationId(), parentUser2.getUserId(), false, null);

        // Notification 5: Event announcement
        Notification n5 = saveNotification("Thông báo Ngày hội Công nghệ FPT Tech Fest 2026",
                "Trường Đại học FPT trân trọng mời Phụ huynh và Sinh viên tham dự sự kiện FPT Tech Fest 2026 "
                + "diễn ra vào ngày 20/10/2026 tại sảnh chính Tòa Alpha.\n\n"
                + "Chương trình bao gồm:\n- Triển lãm đồ án sinh viên\n- Hội thảo về AI và IoT\n"
                + "- Giao lưu doanh nghiệp\n\nĐăng ký tham dự tại cổng thông tin sinh viên.",
                adminUser.getUserId(), "ALL", now.minusDays(2));
        saveNotificationRecipient(n5.getNotificationId(), parentUser1.getUserId(), false, null);
        saveNotificationRecipient(n5.getNotificationId(), parentUser2.getUserId(), false, null);
        saveNotificationRecipient(n5.getNotificationId(), parentUser3.getUserId(), false, null);

        // Notification 6: Overdue fee warning
        Notification n6 = saveNotification("Cảnh báo: Học phí quá hạn",
                "Kính gửi Phụ huynh,\n\nHọc phí kỳ Fall 2026 của sinh viên Trần Đức Mạnh (SE17015) đã quá hạn thanh toán. "
                + "Số tiền còn thiếu: 14.500.000 VNĐ.\n\nĐề nghị phụ huynh hoàn tất thanh toán trước ngày 30/10/2026 "
                + "để tránh ảnh hưởng đến việc học.\n\nTrân trọng,\nPhòng Tài chính",
                adminUser.getUserId(), "PARENT", now.minusDays(1));
        saveNotificationRecipient(n6.getNotificationId(), parentUser2.getUserId(), false, null);

        // Notification 7: Parent meeting
        Notification n7 = saveNotification("Lịch họp phụ huynh giữa kỳ Fall 2026",
                "Kính gửi Quý Phụ huynh,\n\nNhà trường tổ chức buổi họp phụ huynh giữa kỳ Fall 2026 vào:\n"
                + "- Thời gian: 14:00 - 16:00, Thứ Bảy ngày 25/10/2026\n"
                + "- Địa điểm: Hội trường A1, Tầng 1 Tòa Alpha\n\n"
                + "Nội dung: Báo cáo kết quả học tập, trao đổi với giảng viên.\n"
                + "Vui lòng xác nhận tham dự qua hệ thống.\n\nTrân trọng.",
                adminUser.getUserId(), "PARENT", now);
        saveNotificationRecipient(n7.getNotificationId(), parentUser1.getUserId(), false, null);
        saveNotificationRecipient(n7.getNotificationId(), parentUser2.getUserId(), false, null);
        saveNotificationRecipient(n7.getNotificationId(), parentUser3.getUserId(), false, null);

        System.out.println("══════════════════════════════════════════════════");
        System.out.println("✅ Database seeding completed successfully!");
        System.out.println("══════════════════════════════════════════════════");
        System.out.println("📋 Seeded Data Summary:");
        System.out.println("   • 13 Users (1 admin, 3 teachers, 1 staff, 3 parents, 5 students)");
        System.out.println("   • 5 Roles with assignments");
        System.out.println("   • 6 Semesters (2 năm × 3 kỳ Fall/Spring/Summer)");
        System.out.println("   • 7 Subjects");
        System.out.println("   • 5 Rooms, 4 Time Slots");
        System.out.println("   • Classes + enrollments cho Fall/Spring/Summer (đủ filter admin)");
        System.out.println("   • 36+ Schedule entries across 4 weeks");
        System.out.println("   • 56+ Attendance records");
        System.out.println("   • 6 Grade Components, 16 Class Grade Components");
        System.out.println("   • 24+ Student Grades");
        System.out.println("   • 2 Final Grades (completed semester)");
        System.out.println("   • 3 Fee Types, 12 Student Fees, 9 Fee Payments");
        System.out.println("   • 7 Notifications with recipients");
        System.out.println("══════════════════════════════════════════════════");
        System.out.println("🔑 Login credentials (password: 123456 for all):");
        System.out.println("   Parent 1: parent1 / parent1@example.com");
        System.out.println("   Parent 2: parent2 / parent2@example.com");
        System.out.println("   Parent 3: parent3 / parent3@example.com");
        System.out.println("   Student:  student1 ~ student5");
        System.out.println("   Teacher:  teacher1 ~ teacher3");
        System.out.println("   Admin:    admin");
        System.out.println("══════════════════════════════════════════════════");
    }

    // ═══════════════════════════════════════════════════════════════════
    // Helper methods
    // ═══════════════════════════════════════════════════════════════════

    private void seedApplicationTypesIfEmpty() {
        if (applicationTypeRepository.count() > 0) return;
        saveApplicationType("Xin nghỉ học", "Đơn xin nghỉ phép / nghỉ học có lý do");
        saveApplicationType("Xin miễn giảm học phí", "Đơn đề nghị miễn giảm học phí");
        saveApplicationType("Xin xác nhận sinh viên", "Đơn xin giấy xác nhận sinh viên");
        saveApplicationType("Khiếu nại điểm", "Đơn khiếu nại / phúc khảo điểm");
        saveApplicationType("Khác", "Các loại đơn khác");
        System.out.println("Seeded ApplicationTypes.");
    }

    /**
     * Khi DB đã có user (full seed bị skip), vẫn bổ sung học kỳ + lớp demo
     * để filter Năm học / Kỳ trên Admin Dashboard có dữ liệu.
     * Ưu tiên tái sử dụng học kỳ đã có (tránh trùng FA26 vs FA2026).
     */
    private void ensureSemesterFilterDemoData() {
        LocalDateTime now = LocalDateTime.now();
        System.out.println("🔁 Ensuring semester filter demo data...");

        Semester fall2526 = findOrCreateSemester("Fall", "2025-2026", "FA25", "Fall 2025",
                LocalDate.of(2025, 9, 1), LocalDate.of(2025, 12, 31), "Completed", now);
        Semester spring2526 = findOrCreateSemester("Spring", "2025-2026", "SP26", "Spring 2026",
                LocalDate.of(2026, 1, 5), LocalDate.of(2026, 4, 30), "Completed", now);
        Semester summer2526 = findOrCreateSemester("Summer", "2025-2026", "SU26", "Summer 2026",
                LocalDate.of(2026, 5, 5), LocalDate.of(2026, 8, 31), "Completed", now);
        Semester fall2627 = findOrCreateSemester("Fall", "2026-2027", "FA26", "Fall 2026",
                LocalDate.of(2026, 9, 1), LocalDate.of(2026, 12, 31), "Active", now);
        findOrCreateSemester("Spring", "2026-2027", "SP27", "Spring 2027",
                LocalDate.of(2027, 1, 5), LocalDate.of(2027, 4, 30), "Active", now);
        findOrCreateSemester("Summer", "2026-2027", "SU27", "Summer 2027",
                LocalDate.of(2027, 5, 5), LocalDate.of(2027, 8, 31), "Active", now);

        List<Student> students = studentRepository.findAll();
        List<Teacher> teachers = teacherRepository.findAll();
        List<Subject> subjects = subjectRepository.findAll();

        if (students.size() < 2 || teachers.isEmpty() || subjects.isEmpty()) {
            System.out.println("⚠ Not enough base data (students/teachers/subjects) to seed filter classes.");
            System.out.println("   Academic years available: " + semesterRepository.findDistinctAcademicYears());
            return;
        }

        Teacher t1 = teachers.get(0);
        Teacher t2 = teachers.size() > 1 ? teachers.get(1) : t1;
        Subject sub1 = subjects.get(0);
        Subject sub2 = subjects.size() > 1 ? subjects.get(1) : sub1;
        Subject sub3 = subjects.size() > 2 ? subjects.get(2) : sub1;
        Student s1 = students.get(0);
        Student s2 = students.get(1);
        Student s3 = students.size() > 2 ? students.get(2) : s1;
        Student s4 = students.size() > 3 ? students.get(3) : s2;

        // 2025-2026 Fall — 3 SV
        seedDemoClass("ADM-FA25-A", "Demo Fall 2025 A", sub1, fall2526, t1, now,
                List.of(s1, s2, s3), now.minusMonths(10));
        seedDemoClass("ADM-FA25-B", "Demo Fall 2025 B", sub2, fall2526, t2, now,
                List.of(s1, s2), now.minusMonths(10));

        // 2025-2026 Spring — 2 SV
        seedDemoClass("ADM-SP26-A", "Demo Spring 2026 A", sub1, spring2526, t1, now,
                List.of(s1, s3), now.minusMonths(6));
        seedDemoClass("ADM-SP26-B", "Demo Spring 2026 B", sub3, spring2526, t2, now,
                List.of(s3, s4), now.minusMonths(6));

        // 2025-2026 Summer — 3 SV
        seedDemoClass("ADM-SU26-A", "Demo Summer 2026 A", sub2, summer2526, t1, now,
                List.of(s2, s4), now.minusMonths(3));
        seedDemoClass("ADM-SU26-B", "Demo Summer 2026 B", sub1, summer2526, t2, now,
                List.of(s2, s1, s4), now.minusMonths(3));

        // 2026-2027 Fall — 4 SV (kỳ đang Active)
        seedDemoClass("ADM-FA26-A", "Demo Fall 2026 A", sub1, fall2627, t1, now,
                List.of(s1, s2, s3, s4), now.minusDays(20));
        seedDemoClass("ADM-FA26-B", "Demo Fall 2026 B", sub2, fall2627, t2, now,
                List.of(s1, s2, s3), now.minusDays(20));
        seedDemoClass("ADM-FA26-C", "Demo Fall 2026 C", sub3, fall2627, t1, now,
                List.of(s2, s4), now.minusDays(20));

        System.out.println("✅ Semester filter demo data ready.");
        System.out.println("   Academic years: " + semesterRepository.findDistinctAcademicYears());
        System.out.println("   Tip: chọn 2025-2026 (Fall/Spring/Summer) hoặc 2026-2027 + Fall để thấy số liệu.");
    }

    /** Tìm học kỳ theo năm + kỳ trước; không có mới tạo theo code. */
    private Semester findOrCreateSemester(String term, String academicYear, String code, String name,
                                          LocalDate start, LocalDate end, String status, LocalDateTime now) {
        List<Semester> inYear = semesterRepository.findByAcademicYearOrderByStartDateAsc(academicYear);
        for (Semester s : inYear) {
            if (termEquals(s, term)) {
                return s;
            }
        }
        return semesterRepository.findBySemesterCode(code)
                .orElseGet(() -> saveSemester(code, name, academicYear, start, end, status, now));
    }

    private boolean termEquals(Semester s, String term) {
        String name = s.getSemesterName() != null ? s.getSemesterName().trim().toLowerCase() : "";
        String code = s.getSemesterCode() != null ? s.getSemesterCode().toUpperCase() : "";
        String t = term.toLowerCase();
        if (name.startsWith(t)) return true;
        return switch (t) {
            case "fall" -> code.startsWith("FA");
            case "spring" -> code.startsWith("SP");
            case "summer" -> code.startsWith("SU");
            default -> false;
        };
    }

    private void seedDemoClass(String code, String name, Subject subject, Semester semester,
                               Teacher teacher, LocalDateTime now,
                               List<Student> students, LocalDateTime enrolledAt) {
        SchoolClass c = ensureOpenOrCompletedClass(code, name, subject.getSubjectId(),
                semester.getSemesterId(), teacher.getTeacherId(), 40, now,
                "Completed".equalsIgnoreCase(semester.getStatus()) ? "Completed" : "Open");
        for (Student st : students) {
            ensureEnrollment(c.getClassId(), st.getStudentId(), enrolledAt);
        }
    }

    private SchoolClass ensureOpenOrCompletedClass(String code, String name, int subjectId, int semesterId,
                                                   int teacherId, int maxStudents, LocalDateTime now,
                                                   String status) {
        return schoolClassRepository.findByClassCode(code)
                .orElseGet(() -> {
                    SchoolClass sc = new SchoolClass();
                    sc.setClassCode(code);
                    sc.setClassName(name);
                    sc.setSubjectId(subjectId);
                    sc.setSemesterId(semesterId);
                    sc.setMainTeacherId(teacherId);
                    sc.setMaxStudents(maxStudents);
                    sc.setStatus(status); // Draft|Open|In Progress|Completed|Cancelled
                    sc.setCreatedAt(now);
                    return schoolClassRepository.save(sc);
                });
    }

    private void ensureEnrollment(int classId, int studentId, LocalDateTime enrolledAt) {
        if (!classStudentRepository.existsByClassIdAndStudentId(classId, studentId)) {
            saveClassStudent(classId, studentId, enrolledAt);
        }
    }

    private void saveApplicationType(String name, String desc) {
        ApplicationType t = new ApplicationType();
        t.setTypeName(name);
        t.setDescription(desc);
        t.setIsActive(true);
        applicationTypeRepository.save(t);
    }

    private Role saveRole(String name, String desc, LocalDateTime now) {
        Role r = new Role();
        r.setRoleName(name);
        r.setDescription(desc);
        r.setIsActive(true);
        r.setCreatedAt(now);
        return roleRepository.save(r);
    }

    private FeeType saveFeeType(String name, String desc) {
        FeeType ft = new FeeType();
        ft.setFeeTypeName(name);
        ft.setDescription(desc);
        ft.setIsActive(true);
        return feeTypeRepository.save(ft);
    }

    private GradeComponent saveGradeComponent(String name, String desc, BigDecimal weight) {
        GradeComponent gc = new GradeComponent();
        gc.setComponentName(name);
        gc.setDescription(desc);
        gc.setDefaultWeight(weight);
        gc.setIsActive(true);
        return gradeComponentRepository.save(gc);
    }

    private Room saveRoom(String code, String name, int capacity, String location) {
        Room r = new Room();
        r.setRoomCode(code);
        r.setRoomName(name);
        r.setCapacity(capacity);
        r.setLocation(location);
        r.setStatus("Active");
        return roomRepository.save(r);
    }

    private TimeSlot saveTimeSlot(String code, String name, LocalTime start, LocalTime end) {
        TimeSlot ts = new TimeSlot();
        ts.setSlotCode(code);
        ts.setSlotName(name);
        ts.setStartTime(start);
        ts.setEndTime(end);
        ts.setStatus("Active");
        return timeSlotRepository.save(ts);
    }

    private Semester saveSemester(String code, String name, String year, LocalDate start, LocalDate end, String status, LocalDateTime now) {
        Semester s = new Semester();
        s.setSemesterCode(code);
        s.setSemesterName(name);
        s.setAcademicYear(year);
        s.setStartDate(start);
        s.setEndDate(end);
        s.setStatus(status);
        s.setCreatedAt(now);
        return semesterRepository.save(s);
    }

    private Subject saveSubject(String code, String name, int credits, String desc, LocalDateTime now) {
        Subject s = new Subject();
        s.setSubjectCode(code);
        s.setSubjectName(name);
        s.setCredits(credits);
        s.setDescription(desc);
        s.setStatus("Active");
        s.setCreatedAt(now);
        return subjectRepository.save(s);
    }

    private User saveUser(String username, String passwordHash, String fullName, String email,
                          String phone, LocalDate dob, String gender, String address, LocalDateTime now) {
        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(passwordHash);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setDateOfBirth(dob);
        u.setGender(gender);
        u.setAddress(address);
        u.setStatus("ACTIVE");
        u.setCreatedAt(now);
        return userRepository.save(u);
    }

    private void saveUserRole(int userId, int roleId, LocalDateTime now) {
        UserRole ur = new UserRole();
        ur.setUserId(userId);
        ur.setRoleId(roleId);
        ur.setAssignedAt(now);
        userRoleRepository.save(ur);
    }

    private Teacher saveTeacher(int userId, String code, String dept, String spec, LocalDateTime now) {
        Teacher t = new Teacher();
        t.setUserId(userId);
        t.setTeacherCode(code);
        t.setDepartment(dept);
        t.setSpecialization(spec);
        t.setCreatedAt(now);
        return teacherRepository.save(t);
    }

    private void saveStaff(int userId, String code, String dept, LocalDateTime now) {
        Staff s = new Staff();
        s.setUserId(userId);
        s.setStaffCode(code);
        s.setDepartment(dept);
        s.setCreatedAt(now);
        staffRepository.save(s);
    }

    private Parent saveParent(int userId, String code, String occupation, LocalDateTime now) {
        Parent p = new Parent();
        p.setUserId(userId);
        p.setParentCode(code);
        p.setOccupation(occupation);
        p.setCreatedAt(now);
        return parentRepository.save(p);
    }

    private Student saveStudent(int userId, String code, String major, int enrollYear, LocalDateTime now) {
        Student s = new Student();
        s.setUserId(userId);
        s.setStudentCode(code);
        s.setMajor(major);
        s.setEnrollmentYear(enrollYear);
        s.setAcademicStatus("STUDYING");
        s.setCreatedAt(now);
        return studentRepository.save(s);
    }

    private void saveParentStudent(int parentId, int studentId, String relationship, boolean primary, LocalDateTime now) {
        ParentStudent ps = new ParentStudent();
        ps.setParentId(parentId);
        ps.setStudentId(studentId);
        ps.setRelationship(relationship);
        ps.setIsPrimaryContact(primary);
        ps.setCreatedAt(now);
        parentStudentRepository.save(ps);
    }

    private SchoolClass saveClass(String code, String name, int subjectId, int semesterId,
                                  Integer teacherId, int maxStudents, LocalDateTime now) {
        SchoolClass sc = new SchoolClass();
        sc.setClassCode(code);
        sc.setClassName(name);
        sc.setSubjectId(subjectId);
        sc.setSemesterId(semesterId);
        sc.setMainTeacherId(teacherId);
        sc.setMaxStudents(maxStudents);
        sc.setStatus("Open");
        sc.setCreatedAt(now);
        return schoolClassRepository.save(sc);
    }

    private void saveClassStudent(int classId, int studentId, LocalDateTime enrolledAt) {
        ClassStudent cs = new ClassStudent();
        cs.setClassId(classId);
        cs.setStudentId(studentId);
        cs.setEnrolledAt(enrolledAt);
        cs.setStatus("Active");
        classStudentRepository.save(cs);
    }

    private ClassGradeComponent saveClassGradeComponent(int classId, int gradeComponentId, BigDecimal weight) {
        ClassGradeComponent cgc = new ClassGradeComponent();
        cgc.setClassId(classId);
        cgc.setGradeComponentId(gradeComponentId);
        cgc.setWeight(weight);
        return classGradeComponentRepository.save(cgc);
    }

    private Schedule saveSchedule(int classId, int roomId, int timeSlotId, LocalDate date, int createdBy, LocalDateTime now) {
        Schedule s = new Schedule();
        s.setClassId(classId);
        s.setRoomId(roomId);
        s.setTimeSlotId(timeSlotId);
        s.setScheduleDate(date);
        s.setStatus("Scheduled");
        s.setCreatedBy(createdBy);
        s.setCreatedAt(now);
        return scheduleRepository.save(s);
    }

    private void saveAttendance(int scheduleId, int studentId, String status, int teacherId, LocalDateTime markedAt) {
        Attendance a = new Attendance();
        a.setScheduleId(scheduleId);
        a.setStudentId(studentId);
        a.setStatus(status);
        a.setMarkedByTeacherId(teacherId);
        a.setMarkedAt(markedAt);
        if ("ABSENT".equals(status)) {
            a.setNote("Không phép");
        } else if ("EXCUSED".equals(status)) {
            a.setNote("Có đơn xin phép");
        } else if ("LATE".equals(status)) {
            a.setNote("Đi muộn 15 phút");
        }
        attendanceRepository.save(a);
    }

    private void saveStudentGrade(int studentId, int classId, int classGradeComponentId, BigDecimal score, int teacherId, LocalDateTime now) {
        StudentGrade sg = new StudentGrade();
        sg.setStudentId(studentId);
        sg.setClassId(classId);
        sg.setClassGradeComponentId(classGradeComponentId);
        sg.setScore(score);
        sg.setStatus("Published");
        sg.setEnteredByTeacherId(teacherId);
        sg.setEnteredAt(now);
        
        // Get semesterId from the class
        SchoolClass schoolClass = schoolClassRepository.findById(classId).orElse(null);
        if (schoolClass != null) {
            sg.setSemesterId(schoolClass.getSemesterId());
        }
        
        studentGradeRepository.save(sg);
    }

    private void saveFinalGrade(int classId, int studentId, BigDecimal score, String letter, String result, LocalDateTime publishedAt, int publishedBy) {
        FinalGrade fg = new FinalGrade();
        fg.setClassId(classId);
        fg.setStudentId(studentId);
        fg.setFinalScore(score);
        fg.setLetterGrade(letter);
        fg.setResult(result);
        fg.setStatus("Published");
        fg.setPublishedAt(publishedAt);
        fg.setPublishedBy(publishedBy);
        finalGradeRepository.save(fg);
    }

    private StudentFee saveStudentFee(int studentId, int semesterId, int feeTypeId, BigDecimal amount, BigDecimal paidAmount,
                                      LocalDate dueDate, String status, int createdBy, LocalDateTime now) {
        StudentFee sf = new StudentFee();
        sf.setStudentId(studentId);
        sf.setSemesterId(semesterId);
        sf.setFeeTypeId(feeTypeId);
        sf.setAmount(amount);
        sf.setPaidAmount(paidAmount);
        sf.setDueDate(dueDate);
        sf.setStatus(status);
        sf.setCreatedBy(createdBy);
        sf.setCreatedAt(now);
        return studentFeeRepository.save(sf);
    }

    private void saveFeePayment(int studentFeeId, BigDecimal amount, LocalDateTime paymentDate, String method, String txCode, int receivedBy) {
        FeePayment fp = new FeePayment();
        fp.setStudentFeeId(studentFeeId);
        fp.setAmount(amount);
        fp.setPaymentDate(paymentDate);
        fp.setPaymentMethod(method);
        fp.setTransactionCode(txCode);
        fp.setReceivedBy(receivedBy);
        feePaymentRepository.save(fp);
    }

    private Notification saveNotification(String title, String content, int senderId, String targetType, LocalDateTime createdAt) {
        Notification n = new Notification();
        n.setTitle(title);
        n.setContent(content);
        n.setSenderId(senderId);
        n.setTargetType(targetType);
        n.setIsDeleted(false);
        n.setCreatedAt(createdAt);
        return notificationRepository.save(n);
    }

    private void saveNotificationRecipient(int notificationId, int userId, boolean isRead, LocalDateTime readAt) {
        NotificationRecipient nr = new NotificationRecipient();
        nr.setNotificationId(notificationId);
        nr.setUserId(userId);
        nr.setIsRead(isRead);
        nr.setReadAt(readAt);
        notificationRecipientRepository.save(nr);
    }
}
