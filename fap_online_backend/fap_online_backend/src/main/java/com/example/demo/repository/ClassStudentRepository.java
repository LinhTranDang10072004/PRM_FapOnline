package com.example.demo.repository;

import com.example.demo.entity.ClassStudent;
import com.example.demo.entity.ClassStudentId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClassStudentRepository extends JpaRepository<ClassStudent, ClassStudentId> {

	List<ClassStudent> findByClassId(Integer classId);

	List<ClassStudent> findByStudentId(Integer studentId);

	Optional<ClassStudent> findByClassIdAndStudentId(Integer classId, Integer studentId);

	boolean existsByClassIdAndStudentId(Integer classId, Integer studentId);

	long countByClassId(Integer classId);

	// lay count theo quarter va nam hoc
	@Query("SELECT COUNT(DISTINCT cs.studentId) FROM ClassStudent cs, SchoolClass sc "
			+ "WHERE cs.classId = sc.classId AND sc.semesterId IN :semesterIds")
	long countDistinctStudentsBySemesterIds(@Param("semesterIds") List<Integer> semesterIds);
}
