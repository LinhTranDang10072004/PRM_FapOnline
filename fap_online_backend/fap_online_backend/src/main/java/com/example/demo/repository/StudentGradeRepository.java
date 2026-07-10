package com.example.demo.repository;

import com.example.demo.entity.StudentGrade;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentGradeRepository extends JpaRepository<StudentGrade, Integer> {
    @Query("SELECT sg FROM StudentGrade sg WHERE sg.studentId IN :studentIds AND sg.status = 'PUBLISHED' ORDER BY sg.enteredAt DESC")
    List<StudentGrade> findRecentGradesForStudents(@Param("studentIds") List<Integer> studentIds, Pageable pageable);
}
