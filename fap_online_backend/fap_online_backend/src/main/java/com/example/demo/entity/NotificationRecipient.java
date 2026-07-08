package com.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "NotificationRecipients")
public class NotificationRecipient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "NotificationRecipientId", nullable = false)
    private Integer notificationRecipientId;

    @Column(name = "NotificationId", nullable = false)
    private Integer notificationId;

    @Column(name = "UserId", nullable = false)
    private Integer userId;

    @Column(name = "IsRead", nullable = false)
    private Boolean isRead;

    @Column(name = "ReadAt")
    private LocalDateTime readAt;

    public Integer getNotificationRecipientId() {
        return notificationRecipientId;
    }

    public void setNotificationRecipientId(Integer notificationRecipientId) {
        this.notificationRecipientId = notificationRecipientId;
    }

    public Integer getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(Integer notificationId) {
        this.notificationId = notificationId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Boolean getIsRead() {
        return isRead;
    }

    public void setIsRead(Boolean isRead) {
        this.isRead = isRead;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }

}
