package com.example.demo.dto;
import java.time.LocalDate;
public class TimetableDto {
    private Integer scheduleId;
    private LocalDate scheduleDate;
    private String roomCode;
    private String slotCode;
    private String slotTime; // Start - End time
    private String classCode;
    private String subjectCode;
    private String subjectName;
    private String teacherCode;
    private String scheduleStatus;
    private String attendanceStatus;
    private String attendanceLabel;
    private String statusType;
    private String statusLabel;

    public TimetableDto() {}

    public TimetableDto(Integer scheduleId, LocalDate scheduleDate, String roomCode, String slotCode, String slotTime, String classCode, String subjectCode, String subjectName, String teacherCode, String scheduleStatus, String attendanceStatus, String attendanceLabel, String statusType, String statusLabel) {
        this.scheduleId = scheduleId;
        this.scheduleDate = scheduleDate;
        this.roomCode = roomCode;
        this.slotCode = slotCode;
        this.slotTime = slotTime;
        this.classCode = classCode;
        this.subjectCode = subjectCode;
        this.subjectName = subjectName;
        this.teacherCode = teacherCode;
        this.scheduleStatus = scheduleStatus;
        this.attendanceStatus = attendanceStatus;
        this.attendanceLabel = attendanceLabel;
        this.statusType = statusType;
        this.statusLabel = statusLabel;
    }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }
    public LocalDate getScheduleDate() { return scheduleDate; }
    public void setScheduleDate(LocalDate scheduleDate) { this.scheduleDate = scheduleDate; }
    public String getRoomCode() { return roomCode; }
    public void setRoomCode(String roomCode) { this.roomCode = roomCode; }
    public String getSlotCode() { return slotCode; }
    public void setSlotCode(String slotCode) { this.slotCode = slotCode; }
    public String getSlotTime() { return slotTime; }
    public void setSlotTime(String slotTime) { this.slotTime = slotTime; }
    public String getClassCode() { return classCode; }
    public void setClassCode(String classCode) { this.classCode = classCode; }
    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
    public String getTeacherCode() { return teacherCode; }
    public void setTeacherCode(String teacherCode) { this.teacherCode = teacherCode; }
    public String getScheduleStatus() { return scheduleStatus; }
    public void setScheduleStatus(String scheduleStatus) { this.scheduleStatus = scheduleStatus; }
    public String getAttendanceStatus() { return attendanceStatus; }
    public void setAttendanceStatus(String attendanceStatus) { this.attendanceStatus = attendanceStatus; }
    public String getAttendanceLabel() { return attendanceLabel; }
    public void setAttendanceLabel(String attendanceLabel) { this.attendanceLabel = attendanceLabel; }
    public String getStatusType() { return statusType; }
    public void setStatusType(String statusType) { this.statusType = statusType; }
    public String getStatusLabel() { return statusLabel; }
    public void setStatusLabel(String statusLabel) { this.statusLabel = statusLabel; }
}

