package com.example.demo.repository;

import com.example.demo.entity.ClassGradeComponent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClassGradeComponentRepository
        extends JpaRepository<ClassGradeComponent, Integer> {


    List<ClassGradeComponent> findByClassId(
            Integer classId
    );

}