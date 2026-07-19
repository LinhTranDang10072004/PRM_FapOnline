package com.example.demo.repository;

import com.example.demo.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Integer> {

	Optional<Student> findByUserId(Integer userId);

	List<Student> findAllByStudentIdIn(List<Integer> studentIds);
}
