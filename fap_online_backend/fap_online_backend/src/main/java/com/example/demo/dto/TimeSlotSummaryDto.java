package com.example.demo.dto;

public class TimeSlotSummaryDto {
    private String slotCode;
    private String slotTime;

    public TimeSlotSummaryDto() {}

    public TimeSlotSummaryDto(String slotCode, String slotTime) {
        this.slotCode = slotCode;
        this.slotTime = slotTime;
    }

    public String getSlotCode() { return slotCode; }
    public void setSlotCode(String slotCode) { this.slotCode = slotCode; }
    public String getSlotTime() { return slotTime; }
    public void setSlotTime(String slotTime) { this.slotTime = slotTime; }
}
