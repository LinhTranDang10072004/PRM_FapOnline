package com.example.demo.repository;

import com.example.demo.entity.NotificationRecipient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRecipientRepository extends JpaRepository<NotificationRecipient, Integer> {
    @Query("SELECT COUNT(nr) FROM NotificationRecipient nr WHERE nr.userId = :userId AND nr.isRead = false")
    int countUnreadByUserId(@Param("userId") Integer userId);
    
    @Query("SELECT nr FROM NotificationRecipient nr WHERE nr.userId = :userId ORDER BY nr.notificationRecipientId DESC")
    List<NotificationRecipient> findByUserIdOrderBySentAtDesc(@Param("userId") Integer userId);
}
