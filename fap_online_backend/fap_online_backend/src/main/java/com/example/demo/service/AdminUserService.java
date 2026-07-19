package com.example.demo.service;

import com.example.demo.dto.AdminUserCreateRequest;
import com.example.demo.dto.AdminUserDTO;
import com.example.demo.dto.AdminUserUpdateRequest;

import java.util.List;

public interface AdminUserService {

    List<AdminUserDTO> getUsers(String role, String status, String q);

    AdminUserDTO getUserById(Integer userId);

    AdminUserDTO createUser(AdminUserCreateRequest request);

    AdminUserDTO updateUser(Integer userId, AdminUserUpdateRequest request);

    void deleteUser(Integer userId);

    AdminUserDTO lockUser(Integer userId);

    AdminUserDTO unlockUser(Integer userId);
}
