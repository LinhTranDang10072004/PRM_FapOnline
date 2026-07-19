package com.example.demo.service.impl;

import com.example.demo.dto.AdminRoleDTO;
import com.example.demo.dto.AdminRoleRequest;
import com.example.demo.dto.AdminUserDTO;
import com.example.demo.dto.AssignRoleRequest;
import com.example.demo.entity.Role;
import com.example.demo.entity.User;
import com.example.demo.entity.UserRole;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.RoleRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.UserRoleRepository;
import com.example.demo.service.AdminRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminRoleServiceImpl implements AdminRoleService {

    private final RoleRepository roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final UserRepository userRepository;

    @Override
    public List<AdminRoleDTO> getRoles() {
        return roleRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public AdminRoleDTO getRoleById(Integer roleId) {
        return toDto(findRole(roleId));
    }

    @Override
    @Transactional
    public AdminRoleDTO createRole(AdminRoleRequest request) {
        String roleName = normalizeRoleName(request.getRoleName());
        if (roleRepository.existsByRoleNameIgnoreCase(roleName)) {
            throw new ValidationException("Role đã tồn tại: " + roleName);
        }

        Role role = new Role();
        role.setRoleName(roleName);
        role.setDescription(blankToNull(request.getDescription()));
        role.setIsActive(request.getIsActive() == null || request.getIsActive());
        role.setCreatedAt(LocalDateTime.now());
        return toDto(roleRepository.save(role));
    }

    @Override
    @Transactional
    public AdminRoleDTO updateRole(Integer roleId, AdminRoleRequest request) {
        Role role = findRole(roleId);
        String roleName = normalizeRoleName(request.getRoleName());

        if (roleRepository.existsByRoleNameIgnoreCaseAndRoleIdNot(roleName, roleId)) {
            throw new ValidationException("Role đã tồn tại: " + roleName);
        }

        role.setRoleName(roleName);
        if (request.getDescription() != null) {
            role.setDescription(blankToNull(request.getDescription()));
        }
        if (request.getIsActive() != null) {
            role.setIsActive(request.getIsActive());
        }
        return toDto(roleRepository.save(role));
    }

    @Override
    @Transactional
    public void deleteRole(Integer roleId) {
        Role role = findRole(roleId);
        long count = userRoleRepository.countByRoleId(roleId);
        if (count > 0) {
            throw new ValidationException(
                    "Không thể xóa role đang được gán cho " + count + " user. Hãy thu hồi role trước.");
        }
        roleRepository.delete(role);
    }

    @Override
    @Transactional
    public AdminUserDTO assignRole(AssignRoleRequest request) {
        User user = findActiveUser(request.getUserId());
        Role role = findRole(request.getRoleId());

        if (!Boolean.TRUE.equals(role.getIsActive())) {
            throw new ValidationException("Role đang không hoạt động");
        }
        if (userRoleRepository.existsByUserIdAndRoleId(user.getUserId(), role.getRoleId())) {
            throw new ValidationException("User đã có role này");
        }

        UserRole userRole = new UserRole();
        userRole.setUserId(user.getUserId());
        userRole.setRoleId(role.getRoleId());
        userRole.setAssignedAt(LocalDateTime.now());
        userRoleRepository.save(userRole);

        return toUserDto(user);
    }

    @Override
    @Transactional
    public AdminUserDTO unassignRole(AssignRoleRequest request) {
        User user = findActiveUser(request.getUserId());
        findRole(request.getRoleId());

        if (!userRoleRepository.existsByUserIdAndRoleId(user.getUserId(), request.getRoleId())) {
            throw new ValidationException("User không có role này");
        }

        long remaining = userRoleRepository.findByUserId(user.getUserId()).size();
        if (remaining <= 1) {
            throw new ValidationException("User phải còn ít nhất 1 role");
        }

        userRoleRepository.deleteByUserIdAndRoleId(user.getUserId(), request.getRoleId());
        return toUserDto(user);
    }

    private Role findRole(Integer roleId) {
        return roleRepository.findById(roleId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy role #" + roleId));
    }

    private User findActiveUser(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy user #" + userId));
        if ("Deleted".equalsIgnoreCase(user.getStatus())) {
            throw new ResourceNotFoundException("Không tìm thấy user #" + userId);
        }
        return user;
    }

    private AdminRoleDTO toDto(Role role) {
        return AdminRoleDTO.builder()
                .roleId(role.getRoleId())
                .roleName(role.getRoleName())
                .description(role.getDescription())
                .isActive(role.getIsActive())
                .userCount(userRoleRepository.countByRoleId(role.getRoleId()))
                .createdAt(role.getCreatedAt())
                .build();
    }

    private AdminUserDTO toUserDto(User user) {
        List<String> roles = userRoleRepository.findByUserId(user.getUserId()).stream()
                .map(ur -> roleRepository.findById(ur.getRoleId()).orElse(null))
                .filter(Objects::nonNull)
                .map(Role::getRoleName)
                .collect(Collectors.toList());

        return AdminUserDTO.builder()
                .userId(user.getUserId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .address(user.getAddress())
                .status(user.getStatus())
                .roles(roles)
                .primaryRole(roles.isEmpty() ? null : roles.get(0))
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    private static String normalizeRoleName(String roleName) {
        return roleName.trim().toUpperCase(Locale.ROOT);
    }

    private static String blankToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
