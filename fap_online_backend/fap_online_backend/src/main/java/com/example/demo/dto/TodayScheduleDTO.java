package com.example.demo.dto;


public class TodayScheduleDTO {

    private Integer scheduleId;

    private Integer classId;

    private String classCode;

    private String className;

    private String subjectName;

    private String roomName;

    private String startTime;

    private String endTime;

    private String scheduleDate;


    public TodayScheduleDTO() {
    }


    public TodayScheduleDTO(
            Integer scheduleId,
            Integer classId,
            String classCode,
            String className,
            String subjectName,
            String roomName,
            String startTime,
            String endTime,
            String scheduleDate
    ) {

        this.scheduleId = scheduleId;
        this.classId = classId;
        this.classCode = classCode;
        this.className = className;
        this.subjectName = subjectName;
        this.roomName = roomName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.scheduleDate = scheduleDate;

    }


    public Integer getScheduleId() {
        return scheduleId;
    }


    public void setScheduleId(Integer scheduleId) {
        this.scheduleId = scheduleId;
    }


    public Integer getClassId() {
        return classId;
    }


    public void setClassId(Integer classId) {
        this.classId = classId;
    }


    public String getClassCode() {
        return classCode;
    }


    public void setClassCode(String classCode) {
        this.classCode = classCode;
    }


    public String getClassName() {
        return className;
    }


    public void setClassName(String className) {
        this.className = className;
    }


    public String getSubjectName() {
        return subjectName;
    }


    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }


    public String getRoomName() {
        return roomName;
    }


    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }


    public String getStartTime() {
        return startTime;
    }


    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }


    public String getEndTime() {
        return endTime;
    }


    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }


    public String getScheduleDate() {
        return scheduleDate;
    }


    public void setScheduleDate(String scheduleDate) {
        this.scheduleDate = scheduleDate;
    }

}