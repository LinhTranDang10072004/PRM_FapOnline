package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
@Data @Builder public class GradeReportDTO {
    private String subjectCode;
    private String gradeComponent;
    private BigDecimal score;
    private BigDecimal weight;
}
