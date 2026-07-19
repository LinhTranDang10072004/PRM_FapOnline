package com.example.demo.repository;

import com.example.demo.entity.ClassGradeComponent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClassGradeComponentRepository extends JpaRepository<ClassGradeComponent, Integer> {}
