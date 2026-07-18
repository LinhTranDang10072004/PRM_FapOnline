package com.example.demo.repository;
import java.util.List;
import com.example.demo.entity.ClassStudent;
import com.example.demo.entity.ClassStudentId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClassStudentRepository
        extends JpaRepository<ClassStudent, ClassStudentId> {


    // Đếm số sinh viên trong một lớp
    Integer countByClassId(Integer classId);

    List<ClassStudent> findByClassId(Integer classId);
}