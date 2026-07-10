package com.example.demo.service;

import com.example.demo.dto.ChangePasswordRequest;
import com.example.demo.dto.ProfileDTO;

public interface ParentProfileService {
    ProfileDTO getProfile();
    void updateProfile(ProfileDTO profileDTO);
    void changePassword(ChangePasswordRequest request);
}
