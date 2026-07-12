package com.example.demo.repository;

import com.example.demo.entity.StudentFee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentFeeRepository extends JpaRepository<StudentFee, Integer> {
    @Query("SELECT sf FROM StudentFee sf " +
           "WHERE sf.studentId IN :studentIds " +
           "AND sf.amount > sf.paidAmount " +
           "AND sf.status <> 'PAID'")
    List<StudentFee> findUnpaidFeesForStudents(@Param("studentIds") List<Integer> studentIds);
    
    @Query("SELECT sf FROM StudentFee sf " +
           "WHERE sf.studentId = :studentId " +
           "AND sf.semesterId = :semesterId")
    List<StudentFee> findByStudentAndSemester(
        @Param("studentId") Integer studentId,
        @Param("semesterId") Integer semesterId
    );
    
    @Query("SELECT sf FROM StudentFee sf " +
           "WHERE sf.studentId = :studentId " +
           "AND sf.dueDate < CURRENT_DATE " +
           "AND sf.status = 'UNPAID'")
    List<StudentFee> findOverdueFees(
        @Param("studentId") Integer studentId
    );
    
    @Query("SELECT sf FROM StudentFee sf " +
           "WHERE sf.studentId = :studentId")
    List<StudentFee> findByStudentId(
        @Param("studentId") Integer studentId
    );
}
