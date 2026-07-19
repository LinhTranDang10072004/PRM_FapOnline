package com.example.demo.dto;

import java.util.List;

public class AttendanceRequestDTO {

    private Integer scheduleId;

    private Integer userId;

    private List<AttendanceItemDTO> attendanceList;

    public AttendanceRequestDTO() {
    }

    public AttendanceRequestDTO(
            Integer scheduleId,
            Integer userId,
            List<AttendanceItemDTO> attendanceList) {

        this.scheduleId = scheduleId;
        this.userId = userId;
        this.attendanceList = attendanceList;
    }

    public Integer getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(Integer scheduleId) {
        this.scheduleId = scheduleId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public List<AttendanceItemDTO> getAttendanceList() {
        return attendanceList;
    }

    public void setAttendanceList(List<AttendanceItemDTO> attendanceList) {
        this.attendanceList = attendanceList;
    }

}