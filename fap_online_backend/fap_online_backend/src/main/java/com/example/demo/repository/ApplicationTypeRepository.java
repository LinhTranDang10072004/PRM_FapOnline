package com.example.demo.repository;

import com.example.demo.entity.ApplicationType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ApplicationTypeRepository extends JpaRepository<ApplicationType, Integer> {
    List<ApplicationType> findByIsActiveTrue();
}
