package com.example.demo.repository;

import com.example.demo.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Integer> {

    List<Schedule> findByClassIdIn(List<Integer> classIds);
    List<Schedule> findByClassIdInOrderByScheduleDateAscTimeSlotIdAsc(
            List<Integer> classIds
    );

}