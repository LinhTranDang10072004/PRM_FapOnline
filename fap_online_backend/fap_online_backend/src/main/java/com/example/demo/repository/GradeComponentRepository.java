package com.example.demo.repository;

import com.example.demo.entity.GradeComponent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GradeComponentRepository extends JpaRepository<GradeComponent, Integer> {}
