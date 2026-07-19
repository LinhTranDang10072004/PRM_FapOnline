package com.example.demo.dto;

public class DashboardSummaryDto {
    private Integer unreadNotifications;
    private String nextClassSubject;
    private String nextClassTime;
    private String nextClassRoom;

    public Integer getUnreadNotifications() { return unreadNotifications; }
    public void setUnreadNotifications(Integer unreadNotifications) { this.unreadNotifications = unreadNotifications; }
    public String getNextClassSubject() { return nextClassSubject; }
    public void setNextClassSubject(String nextClassSubject) { this.nextClassSubject = nextClassSubject; }
    public String getNextClassTime() { return nextClassTime; }
    public void setNextClassTime(String nextClassTime) { this.nextClassTime = nextClassTime; }
    public String getNextClassRoom() { return nextClassRoom; }
    public void setNextClassRoom(String nextClassRoom) { this.nextClassRoom = nextClassRoom; }
}
