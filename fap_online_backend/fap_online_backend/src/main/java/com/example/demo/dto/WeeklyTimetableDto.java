package com.example.demo.dto;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class WeeklyTimetableDto {
    private int year;
    private LocalDate weekStart;
    private LocalDate weekEnd;
    private String weekLabel;
    private List<TimeSlotSummaryDto> slots = new ArrayList<>();
    private List<DayColumnDto> days = new ArrayList<>();
    private List<TimetableDto> entries = new ArrayList<>();

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    public LocalDate getWeekStart() { return weekStart; }
    public void setWeekStart(LocalDate weekStart) { this.weekStart = weekStart; }
    public LocalDate getWeekEnd() { return weekEnd; }
    public void setWeekEnd(LocalDate weekEnd) { this.weekEnd = weekEnd; }
    public String getWeekLabel() { return weekLabel; }
    public void setWeekLabel(String weekLabel) { this.weekLabel = weekLabel; }
    public List<TimeSlotSummaryDto> getSlots() { return slots; }
    public void setSlots(List<TimeSlotSummaryDto> slots) { this.slots = slots; }
    public List<DayColumnDto> getDays() { return days; }
    public void setDays(List<DayColumnDto> days) { this.days = days; }
    public List<TimetableDto> getEntries() { return entries; }
    public void setEntries(List<TimetableDto> entries) { this.entries = entries; }
}
