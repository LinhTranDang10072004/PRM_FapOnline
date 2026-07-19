package com.example.demo.repository;

import com.example.demo.entity.ParentStudent;
import com.example.demo.entity.ParentStudentId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ParentStudentRepository extends JpaRepository<ParentStudent, ParentStudentId> {
    @Query("SELECT ps.studentId FROM ParentStudent ps WHERE ps.parentId = :parentId")
    List<Integer> findStudentIdsByParentId(@Param("parentId") Integer parentId);
}
