package com.example.demo.service.impl;

import com.example.demo.dto.ChangePasswordRequest;
import com.example.demo.dto.ProfileDTO;
import com.example.demo.entity.User;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.ParentProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.example.demo.util.SecurityUtils;

@Service
@RequiredArgsConstructor
public class ParentProfileServiceImpl implements ParentProfileService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public ProfileDTO getProfile() {
        Integer userId = SecurityUtils.extractUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                
        return ProfileDTO.builder()
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .address(user.getAddress())
                .avatarUrl(user.getAvatarUrl())
                .build();
    }

    @Override
    public void updateProfile(ProfileDTO profileDTO) {
        Integer userId = SecurityUtils.extractUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                
        // Update allowed fields including fullName
        if (profileDTO.getFullName() != null) user.setFullName(profileDTO.getFullName());
        if (profileDTO.getPhone() != null) user.setPhone(profileDTO.getPhone());
        if (profileDTO.getAddress() != null) user.setAddress(profileDTO.getAddress());
        if (profileDTO.getAvatarUrl() != null) user.setAvatarUrl(profileDTO.getAvatarUrl());
        
        if (profileDTO.getEmail() != null && !profileDTO.getEmail().equals(user.getEmail())) {
            if (userRepository.existsByEmailAndUserIdNot(profileDTO.getEmail(), userId)) {
                throw new com.example.demo.exception.ValidationException("Email đã được sử dụng bởi người dùng khác");
            }
            user.setEmail(profileDTO.getEmail());
        }
        
        userRepository.save(user);
    }

    @Override
    public void changePassword(ChangePasswordRequest request) {
        Integer userId = SecurityUtils.extractUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new org.springframework.security.authentication.BadCredentialsException("Mật khẩu cũ không chính xác");
        }
        
        if (passwordEncoder.matches(request.getNewPassword(), user.getPasswordHash())) {
            throw new com.example.demo.exception.ValidationException("Mật khẩu mới không được trùng với mật khẩu cũ");
        }
        
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }
}
