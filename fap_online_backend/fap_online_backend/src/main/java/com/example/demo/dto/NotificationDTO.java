package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data 
@Builder 
public class NotificationDTO {
    private Integer notificationId;
    private String title;
    private String message;
    private LocalDateTime sentAt;
    private Boolean isRead;
}
