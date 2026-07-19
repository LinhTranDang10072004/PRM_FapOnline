package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * UC-18: Staff duyệt đơn từ (Approve).
 * processNote là tùy chọn khi duyệt, bắt buộc khi từ chối (xử lý bên service).
 */
@Data
public class ProcessApplicationRequest {

    @Size(max = 1000, message = "Ghi chú không được vượt quá 1000 ký tự")
    private String processNote;
}
