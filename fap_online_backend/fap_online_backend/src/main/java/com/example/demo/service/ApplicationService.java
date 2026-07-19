package com.example.demo.service;

import com.example.demo.dto.ApplicationDTO;
import com.example.demo.dto.ProcessApplicationRequest;

import java.util.List;

/**
 * UC-18: Process Application — Staff xem và xử lý đơn từ của sinh viên.
 */
public interface ApplicationService {

	List<ApplicationDTO> getApplications(String status);

	ApplicationDTO getApplicationById(Integer applicationId);

	ApplicationDTO approveApplication(Integer applicationId, ProcessApplicationRequest request);

	ApplicationDTO rejectApplication(Integer applicationId, ProcessApplicationRequest request);
}
