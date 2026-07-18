package com.example.demo.service;

import com.example.demo.dto.AttendanceItemDTO;
import com.example.demo.dto.AttendanceRequestDTO;
import com.example.demo.dto.AttendanceStudentDTO;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class AttendanceService {
    @Autowired
    private TeacherRepository teacherRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private ClassStudentRepository classStudentRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private UserRepository userRepository;

    // Lấy danh sách sinh viên để điểm danh
    public List<AttendanceStudentDTO> getAttendanceBySchedule(
            Integer scheduleId) {

        List<AttendanceStudentDTO> result = new ArrayList<>();

        Optional<Schedule> scheduleOptional =
                scheduleRepository.findById(scheduleId);

        if (scheduleOptional.isEmpty()) {
            return result;
        }

        Schedule schedule = scheduleOptional.get();

        List<ClassStudent> classStudents =
                classStudentRepository.findByClassId(
                        schedule.getClassId()
                );

        for (ClassStudent classStudent : classStudents) {

            Optional<Student> studentOptional =
                    studentRepository.findById(
                            classStudent.getStudentId()
                    );

            if (studentOptional.isEmpty()) {
                continue;
            }

            Student student = studentOptional.get();

            String fullName = "";

            Optional<User> userOptional =
                    userRepository.findById(
                            student.getUserId()
                    );

            if (userOptional.isPresent()) {
                fullName =
                        userOptional.get().getFullName();
            }

            String status = "AbsentWithoutPermission";

            String note = "";

            Optional<Attendance> attendanceOptional =
                    attendanceRepository
                            .findByScheduleIdAndStudentId(
                                    scheduleId,
                                    student.getStudentId()
                            );

            if (attendanceOptional.isPresent()) {

                status =
                        attendanceOptional.get().getStatus();

                note =
                        attendanceOptional.get().getNote();
            }

            AttendanceStudentDTO dto =
                    new AttendanceStudentDTO(
                            student.getStudentId(),
                            student.getStudentCode(),
                            fullName,
                            status,
                            note
                    );

            result.add(dto);
        }

        return result;
    }
    // Lưu điểm danh
    public void saveAttendance(AttendanceRequestDTO request) {
        Teacher teacher =
                teacherRepository
                        .findByUserId(request.getUserId())
                        .orElseThrow(() ->
                                new RuntimeException("Teacher not found"));
        for (AttendanceItemDTO item : request.getAttendanceList()) {

            Optional<Attendance> attendanceOptional =
                    attendanceRepository.findByScheduleIdAndStudentId(
                            request.getScheduleId(),
                            item.getStudentId()
                    );

            Attendance attendance;

            if (attendanceOptional.isPresent()) {

                // Đã có điểm danh -> cập nhật
                attendance = attendanceOptional.get();

                attendance.setStatus(
                        item.getStatus()
                );

                attendance.setNote(
                        item.getNote()
                );

                attendance.setUpdatedAt(
                        LocalDateTime.now()
                );

            } else {

                // Chưa có -> tạo mới
                attendance = new Attendance();

                attendance.setScheduleId(
                        request.getScheduleId()
                );

                attendance.setStudentId(
                        item.getStudentId()
                );

                attendance.setStatus(
                        item.getStatus()
                );

                attendance.setNote(
                        item.getNote()
                );

                attendance.setMarkedByTeacherId(
                        teacher.getTeacherId()
                );

                attendance.setMarkedAt(
                        LocalDateTime.now()
                );
            }

            attendanceRepository.save(attendance);

        }
    }
}