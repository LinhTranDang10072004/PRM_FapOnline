package com.example.demo.repository;

import com.example.demo.entity.Application;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ApplicationRepository extends JpaRepository<Application, Integer> {

	List<Application> findByStatus(String status);

	List<Application> findByStudentId(Integer studentId);

	List<Application> findByStudentIdAndStatus(Integer studentId, String status);

	List<Application> findByStudentIdOrderByCreatedAtDesc(Integer studentId);
}
