package com.example.demo.controller;

import com.example.demo.dto.NotificationDTO;
import com.example.demo.service.ParentNotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/parent/notifications")
@RequiredArgsConstructor
@Tag(name = "Parent Notifications", description = "Endpoints for parents to manage notifications")
public class ParentNotificationController {

    private final ParentNotificationService parentNotificationService;
    @GetMapping
    @Operation(summary = "Get notifications", description = "Retrieves all notifications for the authenticated parent")
    public ResponseEntity<List<NotificationDTO>> getNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(parentNotificationService.getNotifications(page, size));
    }

    @PutMapping("/{notificationId}/read")
    @Operation(summary = "Mark notification as read", description = "Marks a specific notification as read")
    public ResponseEntity<Void> markAsRead(
            @Parameter(description = "ID of the notification recipient record") @PathVariable Integer notificationId) {
        parentNotificationService.markNotificationAsRead(notificationId);
        return ResponseEntity.noContent().build();
    }
}
