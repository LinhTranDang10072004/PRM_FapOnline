package com.example.demo.repository;

import com.example.demo.entity.FinalGrade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FinalGradeRepository extends JpaRepository<FinalGrade, Integer> {
	List<FinalGrade> findByStudentId(Integer studentId);
}
