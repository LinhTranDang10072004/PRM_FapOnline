package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
@Data @Builder public class TranscriptDTO {
    private String subjectCode;
    private String subjectName;
    private BigDecimal finalScore;
    private String status;
}
