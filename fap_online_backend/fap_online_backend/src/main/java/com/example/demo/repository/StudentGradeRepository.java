package com.example.demo.repository;

import com.example.demo.dto.GradeItemDTO;
import com.example.demo.entity.StudentGrade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentGradeRepository
        extends JpaRepository<StudentGrade, Integer> {


    @Query("""
            SELECT new com.example.demo.dto.GradeItemDTO(
                sg.studentGradeId,
                sg.studentId,
                u.fullName,
                s.studentCode,
                sg.classGradeComponentId,
                gc.componentName,
                cgc.weight,
                sg.score,
                sg.status
            )

            FROM StudentGrade sg

            JOIN Student s
                ON sg.studentId = s.studentId

            JOIN User u
                ON s.userId = u.userId

            JOIN ClassGradeComponent cgc
                ON sg.classGradeComponentId =
                   cgc.classGradeComponentId

            JOIN GradeComponent gc
                ON cgc.gradeComponentId =
                   gc.gradeComponentId

            WHERE sg.classId = :classId

            ORDER BY s.studentId
            """)
    List<GradeItemDTO> getGradeItemsByClassId(
            @Param("classId") Integer classId
    );



    List<StudentGrade> findByStudentId(
            Integer studentId
    );


    List<StudentGrade> findByClassId(
            Integer classId
    );



    StudentGrade findByStudentIdAndClassGradeComponentIdAndClassId(
            Integer studentId,
            Integer classGradeComponentId,
            Integer classId
    );

}