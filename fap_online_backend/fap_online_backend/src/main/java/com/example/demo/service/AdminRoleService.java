package com.example.demo.service;

import com.example.demo.dto.AdminRoleDTO;
import com.example.demo.dto.AdminRoleRequest;
import com.example.demo.dto.AdminUserDTO;
import com.example.demo.dto.AssignRoleRequest;

import java.util.List;

public interface AdminRoleService {

    List<AdminRoleDTO> getRoles();

    AdminRoleDTO getRoleById(Integer roleId);

    AdminRoleDTO createRole(AdminRoleRequest request);

    AdminRoleDTO updateRole(Integer roleId, AdminRoleRequest request);

    void deleteRole(Integer roleId);

    AdminUserDTO assignRole(AssignRoleRequest request);

    AdminUserDTO unassignRole(AssignRoleRequest request);
}
