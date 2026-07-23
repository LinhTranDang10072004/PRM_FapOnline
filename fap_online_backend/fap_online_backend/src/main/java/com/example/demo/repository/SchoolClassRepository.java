package com.example.demo.repository;

import com.example.demo.entity.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SchoolClassRepository extends JpaRepository<SchoolClass, Integer> {
    boolean existsByClassCode(String classCode);
    boolean existsByClassCodeAndClassIdNot(String classCode, Integer classId);
    Optional<SchoolClass> findByClassCode(String classCode);
    List<SchoolClass> findByMainTeacherId(Integer teacherId);
    List<SchoolClass> findBySemesterId(Integer semesterId);

    long countBySemesterIdIn(List<Integer> semesterIds);

    /** UC-12: Đếm lớp có giáo viên được phân công */
    long countByMainTeacherIdIsNotNull();

    /** UC-12: Đếm lớp KHÔNG thuộc các trạng thái kết thúc (Cancelled, Completed) */
    long countByStatusNotIn(List<String> excludedStatuses);

    @Query("SELECT COUNT(DISTINCT sc.mainTeacherId) FROM SchoolClass sc "
            + "WHERE sc.semesterId IN :semesterIds AND sc.mainTeacherId IS NOT NULL")
    long countDistinctTeachersBySemesterIds(@Param("semesterIds") List<Integer> semesterIds);

    @Query("SELECT COUNT(DISTINCT sc.subjectId) FROM SchoolClass sc "
            + "WHERE sc.semesterId IN :semesterIds")
    long countDistinctSubjectsBySemesterIds(@Param("semesterIds") List<Integer> semesterIds);
}
