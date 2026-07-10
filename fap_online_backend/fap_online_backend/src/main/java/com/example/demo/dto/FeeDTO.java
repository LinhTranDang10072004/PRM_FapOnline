package com.example.demo.dto;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
@Data @Builder public class FeeDTO {
    private Integer feeId;
    private String feeType;
    private BigDecimal amount;
    private BigDecimal paidAmount;
    private LocalDate dueDate;
    private String status;
}
