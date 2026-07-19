package com.example.demo.dto;

import java.math.BigDecimal;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecentGradeDTO {
    private Integer studentId;
    private String studentName;
    private String subjectCode;
    private String gradeComponent;
    private BigDecimal score;
    private String enteredAt;
}
