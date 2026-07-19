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
    @Query("SELECT DISTINCT s FROM Schedule s " +
            "JOIN ClassStudent cs ON s.classId = cs.classId " +
            "WHERE cs.studentId IN :studentIds AND s.scheduleDate = :today " +
            "ORDER BY s.timeSlotId ASC")
    List<Schedule> findTodaySchedulesForStudents(@Param("studentIds") List<Integer> studentIds, @Param("today") LocalDate today);

    @Query("SELECT DISTINCT s FROM Schedule s " +
            "JOIN ClassStudent cs ON s.classId = cs.classId " +
            "WHERE cs.studentId IN :studentIds AND s.scheduleDate >= :startDate AND s.scheduleDate <= :endDate " +
            "ORDER BY s.scheduleDate ASC, s.timeSlotId ASC")
    List<Schedule> findWeeklySchedulesForStudents(@Param("studentIds") List<Integer> studentIds, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    boolean existsByRoomId(Integer roomId);

    boolean existsByTimeSlotId(Integer timeSlotId);

    List<Schedule> findByClassId(Integer classId);

    List<Schedule> findByClassIdIn(List<Integer> classIds);

    List<Schedule> findByScheduleDate(LocalDate scheduleDate);

    List<Schedule> findByRoomIdAndScheduleDateAndTimeSlotId(Integer roomId, LocalDate scheduleDate, Integer timeSlotId);

    List<Schedule> findByClassIdInAndScheduleDateAndTimeSlotId(List<Integer> classIds, LocalDate scheduleDate, Integer timeSlotId);
}