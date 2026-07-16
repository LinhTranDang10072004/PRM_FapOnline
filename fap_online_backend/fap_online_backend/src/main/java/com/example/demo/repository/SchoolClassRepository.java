package com.example.demo.repository;

import com.example.demo.entity.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SchoolClassRepository extends JpaRepository<SchoolClass, Integer> {
    boolean existsByClassCode(String classCode);
    boolean existsByClassCodeAndClassIdNot(String classCode, Integer classId);
    List<SchoolClass> findByMainTeacherId(Integer teacherId);
    List<SchoolClass> findBySemesterId(Integer semesterId);
}