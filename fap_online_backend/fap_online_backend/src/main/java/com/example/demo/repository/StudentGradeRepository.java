package com.example.demo.repository;

import com.example.demo.dto.GradeItemDTO;
import com.example.demo.entity.StudentGrade;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentGradeRepository extends JpaRepository<StudentGrade, Integer> {

	List<StudentGrade> findByStudentId(Integer studentId);

	List<StudentGrade> findByClassId(Integer classId);

	boolean existsByClassId(Integer classId);

	boolean existsByClassIdAndStudentId(Integer classId, Integer studentId);

	StudentGrade findByStudentIdAndClassGradeComponentIdAndClassId(
			Integer studentId,
			Integer classGradeComponentId,
			Integer classId
	);

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
			JOIN Student s ON sg.studentId = s.studentId
			JOIN User u ON s.userId = u.userId
			JOIN ClassGradeComponent cgc ON sg.classGradeComponentId = cgc.classGradeComponentId
			JOIN GradeComponent gc ON cgc.gradeComponentId = gc.gradeComponentId
			WHERE sg.classId = :classId
			ORDER BY s.studentId
			""")
	List<GradeItemDTO> getGradeItemsByClassId(@Param("classId") Integer classId);

	@Query("SELECT sg FROM StudentGrade sg WHERE sg.studentId IN :studentIds AND sg.status = 'PUBLISHED' ORDER BY sg.enteredAt DESC")
	List<StudentGrade> findRecentGradesForStudents(
			@Param("studentIds") List<Integer> studentIds,
			Pageable pageable
	);

	@Query("SELECT sg FROM StudentGrade sg, SchoolClass sc " +
			"WHERE sg.classId = sc.classId " +
			"AND sg.studentId = :studentId " +
			"AND sc.semesterId = :semesterId " +
			"AND sg.status = 'PUBLISHED' " +
			"ORDER BY sg.enteredAt DESC")
	List<StudentGrade> findBySemester(
			@Param("studentId") Integer studentId,
			@Param("semesterId") Integer semesterId
	);

	@Query("SELECT sg FROM StudentGrade sg " +
			"WHERE sg.studentId = :studentId " +
			"AND sg.status = 'PUBLISHED' " +
			"ORDER BY sg.enteredAt DESC")
	List<StudentGrade> findPublishedGradesByStudent(@Param("studentId") Integer studentId);
}
