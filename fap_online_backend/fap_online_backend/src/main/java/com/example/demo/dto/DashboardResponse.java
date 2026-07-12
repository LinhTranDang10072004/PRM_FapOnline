package com.example.demo.dto;

import java.util.List;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardResponse {
    private List<ChildSummaryDTO> children;
    private int unreadNotificationCount;
    private List<TodayScheduleDTO> todaySchedules;
    private List<RecentGradeDTO> recentGrades;
    private List<UnpaidFeeDTO> unpaidFees;
    private int attendancePresentCount;
    private int attendanceTotalCount;
}
