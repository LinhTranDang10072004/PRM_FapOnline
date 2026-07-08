package com.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "FeePayments")
public class FeePayment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PaymentId", nullable = false)
    private Integer paymentId;

    @Column(name = "StudentFeeId", nullable = false)
    private Integer studentFeeId;

    @Column(name = "Amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "PaymentDate", nullable = false)
    private LocalDateTime paymentDate;

    @Column(name = "PaymentMethod", nullable = false, length = 50)
    private String paymentMethod;

    @Column(name = "TransactionCode", length = 100)
    private String transactionCode;

    @Column(name = "ReceivedBy")
    private Integer receivedBy;

    @Column(name = "Note", length = 500)
    private String note;

    public Integer getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Integer paymentId) {
        this.paymentId = paymentId;
    }

    public Integer getStudentFeeId() {
        return studentFeeId;
    }

    public void setStudentFeeId(Integer studentFeeId) {
        this.studentFeeId = studentFeeId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionCode() {
        return transactionCode;
    }

    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public Integer getReceivedBy() {
        return receivedBy;
    }

    public void setReceivedBy(Integer receivedBy) {
        this.receivedBy = receivedBy;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

}
