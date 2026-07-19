package com.example.demo.repository;

import com.example.demo.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Integer> {
    List<Attendance> findByStudentId(Integer studentId);
}
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface AttendanceRepository extends JpaRepository<Attendance, Integer> {

    List<Attendance> findByStudentIdIn(List<Integer> studentIds);
    
    @Query("SELECT a FROM Attendance a " +
            "WHERE a.studentId = :studentId " +
            "AND a.markedAt >= :startDate " +
            "AND a.markedAt <= :endDate " +
            "ORDER BY a.markedAt DESC")
    List<Attendance> findByStudentAndDateRange(
            @Param("studentId") Integer studentId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT a FROM Attendance a " +
            "WHERE a.studentId = :studentId " +
            "AND YEAR(a.markedAt) = :year " +
            "AND MONTH(a.markedAt) = :month")
    List<Attendance> findMonthlyAttendance(
            @Param("studentId") Integer studentId,
            @Param("year") Integer year,
            @Param("month") Integer month
    );

    boolean existsByScheduleIdIn(List<Integer> scheduleIds);

    boolean existsByStudentIdAndScheduleIdIn(Integer studentId, List<Integer> scheduleIds);

    boolean existsByScheduleId(Integer scheduleId);
}
