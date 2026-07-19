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
public class UnpaidFeeDTO {
    private Integer studentId;
    private String studentName;
    private String feeType;
    private BigDecimal amount;
    private BigDecimal paidAmount;
    private String dueDate;
}
