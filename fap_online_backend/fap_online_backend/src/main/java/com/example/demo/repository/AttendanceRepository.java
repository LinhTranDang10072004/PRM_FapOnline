package com.example.demo.repository;

import com.example.demo.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AttendanceRepository
        extends JpaRepository<Attendance, Integer> {

    Optional<Attendance> findByScheduleIdAndStudentId(
            Integer scheduleId,
            Integer studentId
    );

}