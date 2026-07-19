package com.example.demo.service;

import com.example.demo.dto.DashboardResponse;

public interface ParentDashboardService {
    /**
     * Gets dashboard data for the parent.
     * @param userId The ID of the authenticated parent user.
     * @return DashboardResponse containing children summary, schedules, grades, etc.
     */
    DashboardResponse getDashboardData();
}
