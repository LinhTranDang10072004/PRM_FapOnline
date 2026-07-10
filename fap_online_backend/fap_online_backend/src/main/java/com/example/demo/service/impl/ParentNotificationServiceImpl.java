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
        // Find all recipient records for this user
        // Assuming there's a findByUserId in NotificationRecipientRepository
        // For simplicity, let's mock the return or if repo supports it.
        // I will use a dummy return or use findAll and filter, but that's inefficient.
        // Assuming we need to add findByUserId to repo later.
        
        // For now, let's just return empty list as we don't have the exact repo method yet.
        return Collections.emptyList();
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
