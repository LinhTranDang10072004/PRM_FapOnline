package com.example.demo.repository;

import com.example.demo.entity.Classes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClassesRepository extends JpaRepository<Classes, Integer> {


    // Lấy danh sách lớp mà giáo viên phụ trách
    List<Classes> findByMainTeacherId(Integer teacherId);


    // Lấy các lớp đang hoạt động của giáo viên
    List<Classes> findByMainTeacherIdAndStatus(
            Integer teacherId,
            String status
    );

}