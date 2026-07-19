package com.example.demo.service.impl;

import com.example.demo.dto.AdminProfileDTO;
import com.example.demo.dto.AdminProfileUpdateRequest;
import com.example.demo.dto.ChangePasswordRequest;
import com.example.demo.entity.Role;
import com.example.demo.entity.User;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.RoleRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.UserRoleRepository;
import com.example.demo.service.AdminProfileService;
import com.example.demo.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminProfileServiceImpl implements AdminProfileService {

    private final UserRepository userRepository;
    private final UserRoleRepository userRoleRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public AdminProfileDTO getProfile() {
        return toDto(currentUser());
    }

    @Override
    @Transactional
    public AdminProfileDTO updateProfile(AdminProfileUpdateRequest request) {
        User user = currentUser();

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getEmail() != null && !request.getEmail().isBlank()) {
            String email = request.getEmail().trim();
            if (userRepository.existsByEmailAndUserIdNot(email, user.getUserId())) {
                throw new ValidationException("Email đã được sử dụng bởi người dùng khác");
            }
            user.setEmail(email);
        }
        if (request.getPhone() != null) {
            user.setPhone(blankToNull(request.getPhone()));
        }
        if (request.getGender() != null) {
            user.setGender(blankToNull(request.getGender()));
        }
        if (request.getAddress() != null) {
            user.setAddress(blankToNull(request.getAddress()));
        }

        user.setUpdatedAt(LocalDateTime.now());
        return toDto(userRepository.save(user));
    }

    @Override
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        User user = currentUser();

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Mật khẩu cũ không chính xác");
        }
        if (passwordEncoder.matches(request.getNewPassword(), user.getPasswordHash())) {
            throw new ValidationException("Mật khẩu mới không được trùng với mật khẩu cũ");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    private User currentUser() {
        Integer userId = SecurityUtils.extractUserId();
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy user"));
    }

    private AdminProfileDTO toDto(User user) {
        List<String> roles = userRoleRepository.findByUserId(user.getUserId()).stream()
                .map(ur -> roleRepository.findById(ur.getRoleId()).orElse(null))
                .filter(Objects::nonNull)
                .map(Role::getRoleName)
                .collect(Collectors.toList());

        return AdminProfileDTO.builder()
                .userId(user.getUserId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .address(user.getAddress())
                .avatarUrl(user.getAvatarUrl())
                .status(user.getStatus())
                .roles(roles)
                .build();
    }

    private static String blankToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
