package com.example.demo.service.impl;

import com.example.demo.dto.NotificationDTO;
import com.example.demo.entity.Notification;
import com.example.demo.entity.NotificationRecipient;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.repository.NotificationRecipientRepository;
import com.example.demo.repository.NotificationRepository;
import com.example.demo.service.ParentNotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import com.example.demo.util.SecurityUtils;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParentNotificationServiceImpl implements ParentNotificationService {

    private final NotificationRecipientRepository notificationRecipientRepository;
    private final NotificationRepository notificationRepository;

    @Override
    public List<NotificationDTO> getNotifications(int page, int size) {
        Integer userId = SecurityUtils.extractUserId();
        
        // Get notification recipients for this user ordered by ID (most recent first)
        List<NotificationRecipient> recipients = notificationRecipientRepository.findByUserIdOrderBySentAtDesc(userId);
        
        // Apply pagination manually
        int start = page * size;
        int end = Math.min(start + size, recipients.size());
        
        if (start >= recipients.size()) {
            return Collections.emptyList();
        }
        
        List<NotificationRecipient> paginatedRecipients = recipients.subList(start, end);
        
        // Get notification IDs
        List<Integer> notificationIds = paginatedRecipients.stream()
                .map(NotificationRecipient::getNotificationId)
                .collect(Collectors.toList());
        
        if (notificationIds.isEmpty()) {
            return Collections.emptyList();
        }
        
        // Fetch notifications
        Map<Integer, Notification> notificationMap = notificationRepository.findAllById(notificationIds)
                .stream()
                .collect(Collectors.toMap(Notification::getNotificationId, n -> n));
        
        // Build DTOs
        return paginatedRecipients.stream()
            .map(recipient -> {
                Notification notification = notificationMap.get(recipient.getNotificationId());
                if (notification == null) {
                    return null;
                }
                
                // Use sentAt if available, otherwise use notification's createdAt
                LocalDateTime displayTime = recipient.getSentAt() != null 
                    ? recipient.getSentAt() 
                    : (notification.getCreatedAt() != null ? notification.getCreatedAt() : LocalDateTime.now());
                
                return NotificationDTO.builder()
                        .notificationId(recipient.getNotificationRecipientId())
                        .title(notification.getTitle() != null ? notification.getTitle() : "")
                        .message(notification.getContent() != null ? notification.getContent() : "")
                        .sentAt(displayTime)
                        .isRead(recipient.getIsRead() != null ? recipient.getIsRead() : false)
                        .build();
            })
            .filter(dto -> dto != null)
            .collect(Collectors.toList());
    }

    @Override
    public void markNotificationAsRead(Integer notificationId) {
        Integer userId = SecurityUtils.extractUserId();
        NotificationRecipient recipient = notificationRecipientRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
                
        if (!recipient.getUserId().equals(userId)) {
            throw new AccessDeniedException("Access denied to this notification");
        }
        
        recipient.setIsRead(true);
        notificationRecipientRepository.save(recipient);
    }
}
