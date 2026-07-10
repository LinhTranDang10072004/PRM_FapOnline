package com.example.demo.config;

import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Date;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DatabaseSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ParentRepository parentRepository;
    private final StudentRepository studentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final ScheduleRepository scheduleRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    private final RoomRepository roomRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (userRepository.count() > 0) {
            log.info("Database already seeded. Skipping...");
            return;
        }

        log.info("Seeding database...");

        // Users
        LocalDateTime now = LocalDateTime.now();

        User parentUser = new User();
        parentUser.setUsername("parent1");
        parentUser.setPasswordHash(passwordEncoder.encode("123456"));
        parentUser.setEmail("parent1@example.com");
        parentUser.setFullName("Nguyễn Văn Phụ Huynh");
        parentUser.setStatus("ACTIVE");
        parentUser.setCreatedAt(now);
        parentUser = userRepository.save(parentUser);

        User student1User = new User();
        student1User.setUsername("student1");
        student1User.setPasswordHash(passwordEncoder.encode("123456"));
        student1User.setEmail("student1@example.com");
        student1User.setFullName("Nguyễn Văn B");
        student1User.setStatus("ACTIVE");
        student1User.setCreatedAt(now);
        student1User = userRepository.save(student1User);

        User student2User = new User();
        student2User.setUsername("student2");
        student2User.setPasswordHash(passwordEncoder.encode("123456"));
        student2User.setEmail("student2@example.com");
        student2User.setFullName("Nguyễn Thị C");
        student2User.setStatus("ACTIVE");
        student2User.setCreatedAt(now);
        student2User = userRepository.save(student2User);

        // Parent & Students
        Parent parent = new Parent();
        parent.setUserId(parentUser.getUserId());
        parent.setParentCode("P101");
        parent.setCreatedAt(now);
        parent = parentRepository.save(parent);
        
        Student student1 = new Student();
        student1.setUserId(student1User.getUserId());
        student1.setStudentCode("SE1701");
        student1.setMajor("Software Engineering");
        student1.setAcademicStatus("ACTIVE");
        student1.setCreatedAt(now);
        student1 = studentRepository.save(student1);

        Student student2 = new Student();
        student2.setUserId(student2User.getUserId());
        student2.setStudentCode("MK1701");
        student2.setMajor("Marketing");
        student2.setAcademicStatus("ACTIVE");
        student2.setCreatedAt(now);
        student2 = studentRepository.save(student2);

        ParentStudent ps1 = new ParentStudent();
        ps1.setParentId(parent.getParentId());
        ps1.setStudentId(student1.getStudentId());
        ps1.setRelationship("FATHER");
        ps1.setIsPrimaryContact(true);
        ps1.setCreatedAt(now);
        parentStudentRepository.save(ps1);

        ParentStudent ps2 = new ParentStudent();
        ps2.setParentId(parent.getParentId());
        ps2.setStudentId(student2.getStudentId());
        ps2.setRelationship("FATHER");
        ps2.setIsPrimaryContact(true);
        ps2.setCreatedAt(now);
        parentStudentRepository.save(ps2);

        // Subjects
        Subject prj = new Subject();
        prj.setSubjectCode("PRJ301");
        prj.setSubjectName("Java Web");
        prj.setCredits(3);
        prj.setStatus("ACTIVE");
        prj.setCreatedAt(now);
        prj = subjectRepository.save(prj);

        Subject swp = new Subject();
        swp.setSubjectCode("SWP391");
        swp.setSubjectName("Software Project");
        swp.setCredits(3);
        swp.setStatus("ACTIVE");
        swp.setCreatedAt(now);
        swp = subjectRepository.save(swp);

        Subject mkt = new Subject();
        mkt.setSubjectCode("MKT101");
        mkt.setSubjectName("Marketing");
        mkt.setCredits(3);
        mkt.setStatus("ACTIVE");
        mkt.setCreatedAt(now);
        mkt = subjectRepository.save(mkt);

        // Classes
        SchoolClass class1 = new SchoolClass();
        class1.setClassName("SE1712");
        class1.setSubjectId(prj.getSubjectId());
        class1.setStatus("ACTIVE");
        class1.setCreatedAt(now);
        class1 = schoolClassRepository.save(class1);

        SchoolClass class2 = new SchoolClass();
        class2.setClassName("MK1701");
        class2.setSubjectId(mkt.getSubjectId());
        class2.setStatus("ACTIVE");
        class2.setCreatedAt(now);
        class2 = schoolClassRepository.save(class2);

        // Rooms & Slots
        Room room1 = new Room();
        room1.setRoomName("P.601-T2");
        room1.setRoomCode("R1");
        room1.setStatus("ACTIVE");
        room1 = roomRepository.save(room1);

        Room room2 = new Room();
        room2.setRoomName("P.302-T1");
        room2.setRoomCode("R2");
        room2.setStatus("ACTIVE");
        room2 = roomRepository.save(room2);

        TimeSlot slot1 = new TimeSlot();
        slot1.setSlotName("Slot 1");
        slot1.setSlotCode("S1");
        slot1.setStartTime(LocalTime.of(7, 30));
        slot1.setEndTime(LocalTime.of(9, 0));
        slot1.setStatus("ACTIVE");
        slot1 = timeSlotRepository.save(slot1);

        TimeSlot slot2 = new TimeSlot();
        slot2.setSlotName("Slot 2");
        slot2.setSlotCode("S2");
        slot2.setStartTime(LocalTime.of(9, 30));
        slot2.setEndTime(LocalTime.of(11, 0));
        slot2.setStatus("ACTIVE");
        slot2 = timeSlotRepository.save(slot2);

        // Schedules for current week
        LocalDate today = LocalDate.now();
        LocalDate monday = today.minusDays(today.getDayOfWeek().getValue() - 1);

        // Student 1 Schedule
        Schedule s1 = new Schedule();
        s1.setClassId(class1.getClassId());
        s1.setRoomId(room1.getRoomId());
        s1.setTimeSlotId(slot1.getTimeSlotId());
        s1.setScheduleDate(monday);
        s1.setStatus("Scheduled");
        s1.setCreatedAt(now);
        scheduleRepository.save(s1);

        Schedule s2 = new Schedule();
        s2.setClassId(class2.getClassId());
        s2.setRoomId(room2.getRoomId());
        s2.setTimeSlotId(slot2.getTimeSlotId());
        s2.setScheduleDate(monday.plusDays(1));
        s2.setStatus("Scheduled");
        s2.setCreatedAt(now);
        scheduleRepository.save(s2);

        // Student 2 Schedule
        Schedule s3 = new Schedule();
        s3.setClassId(class2.getClassId());
        s3.setRoomId(room2.getRoomId());
        s3.setTimeSlotId(slot1.getTimeSlotId());
        s3.setScheduleDate(monday);
        s3.setStatus("Scheduled");
        s3.setCreatedAt(now);
        scheduleRepository.save(s3);

        Schedule s4 = new Schedule();
        s4.setClassId(class1.getClassId());
        s4.setRoomId(room1.getRoomId());
        s4.setTimeSlotId(slot2.getTimeSlotId());
        s4.setScheduleDate(monday.plusDays(2));
        s4.setStatus("Scheduled");
        s4.setCreatedAt(now);
        scheduleRepository.save(s4);

        log.info("Seeding completed successfully.");
    }
}
