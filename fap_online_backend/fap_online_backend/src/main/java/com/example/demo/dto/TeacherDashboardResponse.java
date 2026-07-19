package com.example.demo.dto;

import java.util.List;

public class TeacherDashboardResponse {

    private Integer teacherId;
    private String teacherName;

    private Integer totalClasses;

    private Integer todaySchedules;

    private Integer pendingAttendance;

    private Integer pendingGrades;


    private List<TeacherClassDTO> classes;

    private List<TeacherTodayScheduleDTO> todaySchedule;


    public TeacherDashboardResponse(
            Integer teacherId,
            String teacherName,
            Integer totalClasses,
            Integer todaySchedules,
            Integer pendingAttendance,
            Integer pendingGrades,
            List<TeacherClassDTO> classes,
            List<TeacherTodayScheduleDTO> todaySchedule) {

        this.teacherId = teacherId;
        this.teacherName = teacherName;
        this.totalClasses = totalClasses;
        this.todaySchedules = todaySchedules;
        this.pendingAttendance = pendingAttendance;
        this.pendingGrades = pendingGrades;
        this.classes = classes;
        this.todaySchedule = todaySchedule;
    }
    public TeacherDashboardResponse() {
    }



    public TeacherDashboardResponse(
            String teacherName,
            Integer totalClasses,
            Integer todaySchedules,
            Integer pendingAttendance,
            Integer pendingGrades,
            List<TeacherClassDTO> classes,
            List<TeacherTodayScheduleDTO> todaySchedule) {

        this.teacherName = teacherName;
        this.totalClasses = totalClasses;
        this.todaySchedules = todaySchedules;
        this.pendingAttendance = pendingAttendance;
        this.pendingGrades = pendingGrades;
        this.classes = classes;
        this.todaySchedule = todaySchedule;
    }


    public Integer getTeacherId() {
        return teacherId;
    }


    public void setTeacherId(Integer teacherId) {
        this.teacherId = teacherId;
    }
    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }


    public Integer getTotalClasses() {
        return totalClasses;
    }

    public void setTotalClasses(Integer totalClasses) {
        this.totalClasses = totalClasses;
    }


    public Integer getTodaySchedules() {
        return todaySchedules;
    }

    public void setTodaySchedules(Integer todaySchedules) {
        this.todaySchedules = todaySchedules;
    }


    public Integer getPendingAttendance() {
        return pendingAttendance;
    }

    public void setPendingAttendance(Integer pendingAttendance) {
        this.pendingAttendance = pendingAttendance;
    }


    public Integer getPendingGrades() {
        return pendingGrades;
    }

    public void setPendingGrades(Integer pendingGrades) {
        this.pendingGrades = pendingGrades;
    }


    public List<TeacherClassDTO> getClasses() {
        return classes;
    }

    public void setClasses(List<TeacherClassDTO> classes) {
        this.classes = classes;
    }


    public List<TeacherTodayScheduleDTO> getTodaySchedule() {
        return todaySchedule;
    }

    public void setTodaySchedule(List<TeacherTodayScheduleDTO> todaySchedule) {
        this.todaySchedule = todaySchedule;
    }
}