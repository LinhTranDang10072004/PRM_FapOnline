package com.example.demo.repository;

import com.example.demo.entity.Semester;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SemesterRepository extends JpaRepository<Semester, Integer> {

    Optional<Semester> findBySemesterCode(String semesterCode);

    List<Semester> findByAcademicYearOrderByStartDateAsc(String academicYear);

    @Query("SELECT DISTINCT s.academicYear FROM Semester s ORDER BY s.academicYear DESC")
    List<String> findDistinctAcademicYears();

    List<Semester> findAllByOrderByStartDateDesc();
}
