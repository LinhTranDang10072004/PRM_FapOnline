package com.example.demo.repository;

import com.example.demo.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Integer> {

	List<Attendance> findByStudentId(Integer studentId);

	List<Attendance> findByStudentIdIn(List<Integer> studentIds);

	Optional<Attendance> findByScheduleIdAndStudentId(Integer scheduleId, Integer studentId);

	boolean existsByScheduleId(Integer scheduleId);

	boolean existsByScheduleIdIn(List<Integer> scheduleIds);

	boolean existsByStudentIdAndScheduleIdIn(Integer studentId, List<Integer> scheduleIds);

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
}
