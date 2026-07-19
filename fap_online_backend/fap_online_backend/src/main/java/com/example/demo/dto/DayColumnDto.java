package com.example.demo.dto;

import java.time.LocalDate;

public class DayColumnDto {
    private LocalDate date;
    private String dayLabel;
    private String dateLabel;

    public DayColumnDto() {}

    public DayColumnDto(LocalDate date, String dayLabel, String dateLabel) {
        this.date = date;
        this.dayLabel = dayLabel;
        this.dateLabel = dateLabel;
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public String getDayLabel() { return dayLabel; }
    public void setDayLabel(String dayLabel) { this.dayLabel = dayLabel; }
    public String getDateLabel() { return dateLabel; }
    public void setDateLabel(String dateLabel) { this.dateLabel = dateLabel; }
}
