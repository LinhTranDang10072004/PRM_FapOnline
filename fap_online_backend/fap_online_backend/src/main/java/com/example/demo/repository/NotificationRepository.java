package com.example.demo.repository;

import com.example.demo.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

	@Query("SELECT n FROM Notification n JOIN NotificationRecipient nr ON n.notificationId = nr.notificationId WHERE nr.userId = :userId ORDER BY n.createdAt DESC")
	List<Notification> findByUserId(@Param("userId") Integer userId);
}
