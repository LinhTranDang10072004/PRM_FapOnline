package com.example.demo.repository;

import com.example.demo.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Integer> {

	List<Schedule> findByClassId(Integer classId);

	List<Schedule> findByClassIdIn(List<Integer> classIds);

	List<Schedule> findByClassIdInOrderByScheduleDateAsc(List<Integer> classIds);

	List<Schedule> findByClassIdInOrderByScheduleDateAscTimeSlotIdAsc(List<Integer> classIds);

	List<Schedule> findByScheduleDate(LocalDate scheduleDate);

	List<Schedule> findByRoomIdAndScheduleDateAndTimeSlotId(
			Integer roomId,
			LocalDate scheduleDate,
			Integer timeSlotId
	);

	List<Schedule> findByClassIdInAndScheduleDateAndTimeSlotId(
			List<Integer> classIds,
			LocalDate scheduleDate,
			Integer timeSlotId
	);

	boolean existsByRoomId(Integer roomId);

	boolean existsByTimeSlotId(Integer timeSlotId);

	@Query("SELECT DISTINCT s FROM Schedule s " +
			"JOIN ClassStudent cs ON s.classId = cs.classId " +
			"WHERE cs.studentId IN :studentIds AND s.scheduleDate = :today " +
			"ORDER BY s.timeSlotId ASC")
	List<Schedule> findTodaySchedulesForStudents(
			@Param("studentIds") List<Integer> studentIds,
			@Param("today") LocalDate today
	);

	@Query("SELECT DISTINCT s FROM Schedule s " +
			"JOIN ClassStudent cs ON s.classId = cs.classId " +
			"WHERE cs.studentId IN :studentIds AND s.scheduleDate >= :startDate AND s.scheduleDate <= :endDate " +
			"ORDER BY s.scheduleDate ASC, s.timeSlotId ASC")
	List<Schedule> findWeeklySchedulesForStudents(
			@Param("studentIds") List<Integer> studentIds,
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate
	);

	@Query(value = """
			SELECT s.ScheduleId, s.ScheduleDate, r.RoomCode, ts.SlotCode,
			       ts.StartTime, ts.EndTime, c.ClassCode, sub.SubjectCode, sub.SubjectName,
			       t.TeacherCode, s.Status, a.Status
			FROM Schedules s
			JOIN Rooms r ON s.RoomId = r.RoomId
			JOIN TimeSlots ts ON s.TimeSlotId = ts.TimeSlotId
			JOIN Classes c ON s.ClassId = c.ClassId
			JOIN Subjects sub ON c.SubjectId = sub.SubjectId
			JOIN ClassStudents cs ON c.ClassId = cs.ClassId AND cs.StudentId = :studentId AND cs.Status = 'Active'
			LEFT JOIN Teachers t ON c.MainTeacherId = t.TeacherId
			LEFT JOIN Attendances a ON s.ScheduleId = a.ScheduleId AND a.StudentId = :studentId
			WHERE c.ClassId IN (:classIds)
			  AND s.ScheduleDate BETWEEN :fromDate AND :toDate
			  AND s.Status <> 'Cancelled'
			ORDER BY ts.StartTime ASC, s.ScheduleDate ASC
			""", nativeQuery = true)
	List<Object[]> findTimetableEntries(
			@Param("classIds") List<Integer> classIds,
			@Param("studentId") Integer studentId,
			@Param("fromDate") LocalDate fromDate,
			@Param("toDate") LocalDate toDate
	);
}
