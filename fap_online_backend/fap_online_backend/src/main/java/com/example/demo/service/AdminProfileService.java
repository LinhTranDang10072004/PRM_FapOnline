package com.example.demo.service;

import com.example.demo.dto.AdminProfileDTO;
import com.example.demo.dto.AdminProfileUpdateRequest;
import com.example.demo.dto.ChangePasswordRequest;

public interface AdminProfileService {

    AdminProfileDTO getProfile();

    AdminProfileDTO updateProfile(AdminProfileUpdateRequest request);

    void changePassword(ChangePasswordRequest request);
}
