package com.example.demo.service;

import com.example.demo.dto.AttendanceItemDTO;
import com.example.demo.dto.AttendanceRequestDTO;
import com.example.demo.dto.AttendanceStudentDTO;
import com.example.demo.entity.Attendance;
import com.example.demo.entity.ClassStudent;
import com.example.demo.entity.Schedule;
import com.example.demo.entity.Student;
import com.example.demo.entity.Teacher;
import com.example.demo.entity.User;
import com.example.demo.repository.AttendanceRepository;
import com.example.demo.repository.ClassStudentRepository;
import com.example.demo.repository.ScheduleRepository;
import com.example.demo.repository.StudentRepository;
import com.example.demo.repository.TeacherRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class TeacherAttendanceService {

	private final TeacherRepository teacherRepository;
	private final AttendanceRepository attendanceRepository;
	private final ScheduleRepository scheduleRepository;
	private final ClassStudentRepository classStudentRepository;
	private final StudentRepository studentRepository;
	private final UserRepository userRepository;

	public TeacherAttendanceService(
			TeacherRepository teacherRepository,
			AttendanceRepository attendanceRepository,
			ScheduleRepository scheduleRepository,
			ClassStudentRepository classStudentRepository,
			StudentRepository studentRepository,
			UserRepository userRepository
	) {
		this.teacherRepository = teacherRepository;
		this.attendanceRepository = attendanceRepository;
		this.scheduleRepository = scheduleRepository;
		this.classStudentRepository = classStudentRepository;
		this.studentRepository = studentRepository;
		this.userRepository = userRepository;
	}

	public List<AttendanceStudentDTO> getAttendanceBySchedule(Integer scheduleId) {
		List<AttendanceStudentDTO> result = new ArrayList<>();
		Optional<Schedule> scheduleOptional = scheduleRepository.findById(scheduleId);
		if (scheduleOptional.isEmpty()) {
			return result;
		}

		Schedule schedule = scheduleOptional.get();
		List<ClassStudent> classStudents = classStudentRepository.findByClassId(schedule.getClassId());

		for (ClassStudent classStudent : classStudents) {
			Optional<Student> studentOptional = studentRepository.findById(classStudent.getStudentId());
			if (studentOptional.isEmpty()) {
				continue;
			}

			Student student = studentOptional.get();
			String fullName = "";
			Optional<User> userOptional = userRepository.findById(student.getUserId());
			if (userOptional.isPresent()) {
				fullName = userOptional.get().getFullName();
			}

			String status = "AbsentWithoutPermission";
			String note = "";
			Optional<Attendance> attendanceOptional =
					attendanceRepository.findByScheduleIdAndStudentId(scheduleId, student.getStudentId());
			if (attendanceOptional.isPresent()) {
				status = attendanceOptional.get().getStatus();
				note = attendanceOptional.get().getNote();
			}

			result.add(new AttendanceStudentDTO(
					student.getStudentId(),
					student.getStudentCode(),
					fullName,
					status,
					note
			));
		}

		return result;
	}

	public void saveAttendance(AttendanceRequestDTO request) {
		Teacher teacher = teacherRepository.findByUserId(request.getUserId())
				.orElseThrow(() -> new RuntimeException("Teacher not found"));

		for (AttendanceItemDTO item : request.getAttendanceList()) {
			Optional<Attendance> attendanceOptional =
					attendanceRepository.findByScheduleIdAndStudentId(request.getScheduleId(), item.getStudentId());

			Attendance attendance;
			if (attendanceOptional.isPresent()) {
				attendance = attendanceOptional.get();
				attendance.setStatus(item.getStatus());
				attendance.setNote(item.getNote());
				attendance.setUpdatedAt(LocalDateTime.now());
			} else {
				attendance = new Attendance();
				attendance.setScheduleId(request.getScheduleId());
				attendance.setStudentId(item.getStudentId());
				attendance.setStatus(item.getStatus());
				attendance.setNote(item.getNote());
				attendance.setMarkedByTeacherId(teacher.getTeacherId());
				attendance.setMarkedAt(LocalDateTime.now());
			}

			attendanceRepository.save(attendance);
		}
	}
}
