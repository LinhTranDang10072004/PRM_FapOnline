package com.example.demo.repository;

import com.example.demo.entity.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SchoolClassRepository extends JpaRepository<SchoolClass, Integer> {
    boolean existsByClassCode(String classCode);
    boolean existsByClassCodeAndClassIdNot(String classCode, Integer classId);
    List<SchoolClass> findByMainTeacherId(Integer teacherId);
    List<SchoolClass> findBySemesterId(Integer semesterId);

    /** UC-12: Đếm lớp có giáo viên được phân công */
    long countByMainTeacherIdIsNotNull();

    /** UC-12: Đếm lớp KHÔNG thuộc các trạng thái kết thúc (Cancelled, Completed) */
    long countByStatusNotIn(List<String> excludedStatuses);
}