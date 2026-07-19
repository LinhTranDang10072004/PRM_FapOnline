package com.example.demo.repository;

import com.example.demo.entity.Application;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ApplicationRepository extends JpaRepository<Application, Integer> {

    /** Lọc đơn theo trạng thái — dùng cho Staff xem danh sách Pending */
    List<Application> findByStatus(String status);

    /** Lọc đơn theo sinh viên — dùng cho Student xem đơn của mình */
    List<Application> findByStudentId(Integer studentId);

    /** Lọc đơn theo sinh viên VÀ trạng thái */
    List<Application> findByStudentIdAndStatus(Integer studentId, String status);
}
