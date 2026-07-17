package com.example.demo.service;

import com.example.demo.dto.ApplicationDTO;
import com.example.demo.dto.ProcessApplicationRequest;

import java.util.List;

/**
 * UC-18: Process Application — Staff xem và xử lý đơn từ của sinh viên.
 */
public interface ApplicationService {

    /**
     * Bước 1 (luồng chính): Staff xem danh sách đơn.
     * Nếu status = null → trả về toàn bộ.
     * Nếu status = "Pending" → chỉ trả về đơn đang chờ xử lý.
     */
    List<ApplicationDTO> getApplications(String status);

    /**
     * Bước 2 (luồng chính): Staff xem chi tiết một đơn (loại đơn, nội dung,
     * file đính kèm, thông tin sinh viên).
     */
    ApplicationDTO getApplicationById(Integer applicationId);

    /**
     * Bước 3–5 (luồng chính): Staff chọn Approve.
     * BR: Chỉ đơn Pending mới được xử lý.
     * BR: Lưu người xử lý (Staff userId) + thời gian xử lý.
     * BR: processNote là tùy chọn khi approve.
     */
    ApplicationDTO approveApplication(Integer applicationId, ProcessApplicationRequest request);

    /**
     * Bước 3–5 (luồng chính): Staff chọn Reject.
     * BR: Chỉ đơn Pending mới được xử lý.
     * BR: Bắt buộc phải nhập lý do (processNote không được trống).
     * BR: Lưu người xử lý + thời gian xử lý.
     */
    ApplicationDTO rejectApplication(Integer applicationId, ProcessApplicationRequest request);
}
