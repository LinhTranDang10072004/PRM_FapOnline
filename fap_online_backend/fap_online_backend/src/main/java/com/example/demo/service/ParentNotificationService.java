package com.example.demo.service;

import com.example.demo.dto.NotificationDTO;

import java.util.List;

public interface ParentNotificationService {
    List<NotificationDTO> getNotifications(int page, int size);
    void markNotificationAsRead(Integer notificationId);
}
