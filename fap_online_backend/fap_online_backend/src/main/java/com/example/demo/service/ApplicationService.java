package com.example.demo.service;

import com.example.demo.dto.ApplicationDto;
import com.example.demo.entity.Application;
import com.example.demo.entity.Student;
import com.example.demo.repository.ApplicationRepository;
import com.example.demo.repository.StudentRepository;
import com.example.demo.validation.ApplicationSubmitRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ApplicationService {
    @Autowired private ApplicationRepository applicationRepository;
    @Autowired private StudentRepository studentRepository;

    public List<ApplicationDto> getMyApplications(Integer userId) {
        Student student = studentRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Student not found"));
                
        List<Application> apps = applicationRepository.findByStudentIdOrderByCreatedAtDesc(student.getStudentId());
        return apps.stream().map(a -> {
            ApplicationDto dto = new ApplicationDto();
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
