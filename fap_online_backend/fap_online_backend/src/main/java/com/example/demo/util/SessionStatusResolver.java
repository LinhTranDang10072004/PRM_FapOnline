package com.example.demo.util;

import java.time.LocalDate;
import java.time.LocalTime;

public final class SessionStatusResolver {

    private SessionStatusResolver() {}

    /**
     * Quy tắc hiển thị:
     * - Slot tương lai -> not yet
     * - GV đã điểm danh Present/Late -> present
     * - Còn lại (Absent* hoặc chưa điểm danh) -> absent
     */
    public static SessionStatus resolve(
            String scheduleStatus,
            String attendanceStatus,
            LocalDate scheduleDate,
            LocalTime startTime) {

        if ("Cancelled".equalsIgnoreCase(normalize(scheduleStatus))) {
            return new SessionStatus("cancelled", null, scheduleStatus);
        }

        if (isFutureSlot(scheduleDate, startTime)) {
            return new SessionStatus("not_yet", "not yet", scheduleStatus);
        }

        String attendance = normalize(attendanceStatus);
        if ("Present".equals(attendance) || "Late".equals(attendance)) {
            return new SessionStatus("present", "present", scheduleStatus);
        }

        return new SessionStatus("absent", "absent", scheduleStatus);
    }

    private static boolean isFutureSlot(LocalDate scheduleDate, LocalTime startTime) {
        LocalDate today = LocalDate.now();
        if (scheduleDate.isAfter(today)) {
            return true;
        }
        if (scheduleDate.isBefore(today)) {
            return false;
        }
        return startTime != null && LocalTime.now().isBefore(startTime);
    }

    private static String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    public record SessionStatus(String statusType, String statusLabel, String scheduleStatus) {}
}
