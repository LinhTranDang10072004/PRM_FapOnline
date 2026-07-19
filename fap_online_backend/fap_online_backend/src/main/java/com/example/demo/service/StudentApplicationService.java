package com.example.demo.service;

import com.example.demo.dto.StudentApplicationDto;
import com.example.demo.entity.Application;
import com.example.demo.entity.ApplicationType;
import com.example.demo.entity.Student;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.ApplicationRepository;
import com.example.demo.repository.ApplicationTypeRepository;
import com.example.demo.repository.StudentRepository;
import com.example.demo.validation.ApplicationSubmitRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudentApplicationService {

	private final ApplicationRepository applicationRepository;
	private final StudentRepository studentRepository;
	private final ApplicationTypeRepository applicationTypeRepository;

	public StudentApplicationService(
			ApplicationRepository applicationRepository,
			StudentRepository studentRepository,
			ApplicationTypeRepository applicationTypeRepository
	) {
		this.applicationRepository = applicationRepository;
		this.studentRepository = studentRepository;
		this.applicationTypeRepository = applicationTypeRepository;
	}

	public List<ApplicationType> getActiveTypes() {
		return applicationTypeRepository.findByIsActiveTrue();
	}

	public List<StudentApplicationDto> getMyApplications(Integer userId) {
		Student student = studentRepository.findByUserId(userId)
				.orElseThrow(() -> new RuntimeException("Student not found"));

		List<Application> apps = applicationRepository.findByStudentIdOrderByCreatedAtDesc(student.getStudentId());
		return apps.stream().map(a -> {
			StudentApplicationDto dto = new StudentApplicationDto();
			dto.setApplicationId(a.getApplicationId());
			dto.setTitle(a.getTitle());
			dto.setContent(a.getContent());
			dto.setStatus(a.getStatus());
			dto.setStartDate(a.getStartDate());
			dto.setEndDate(a.getEndDate());
			dto.setCreatedAt(a.getCreatedAt());
			return dto;
		}).collect(Collectors.toList());
	}

	public boolean submitApplication(Integer userId, ApplicationSubmitRequest req) {
		Student student = studentRepository.findByUserId(userId)
				.orElseThrow(() -> new RuntimeException("Student not found"));

		ApplicationType type = applicationTypeRepository.findById(req.getApplicationTypeId())
				.orElseThrow(() -> new ValidationException("Loại đơn không hợp lệ"));
		if (!Boolean.TRUE.equals(type.getIsActive())) {
			throw new ValidationException("Loại đơn đang không hoạt động");
		}

		Application app = new Application();
		app.setStudentId(student.getStudentId());
		app.setApplicationTypeId(req.getApplicationTypeId());
		app.setTitle(req.getTitle());
		app.setContent(req.getContent());
		app.setRelatedScheduleId(req.getRelatedScheduleId());
		app.setStartDate(req.getStartDate());
		app.setEndDate(req.getEndDate());
		app.setAttachmentUrl(req.getAttachmentUrl());
		app.setStatus("Pending");
		app.setCreatedAt(LocalDateTime.now());

		applicationRepository.save(app);
		return true;
	}
}
