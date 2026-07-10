package com.example.demo.repository;

import com.example.demo.entity.StudentFee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentFeeRepository extends JpaRepository<StudentFee, Integer> {
    @Query("SELECT sf FROM StudentFee sf WHERE sf.studentId IN :studentIds AND sf.status = 'UNPAID'")
    List<StudentFee> findUnpaidFeesForStudents(@Param("studentIds") List<Integer> studentIds);
}
