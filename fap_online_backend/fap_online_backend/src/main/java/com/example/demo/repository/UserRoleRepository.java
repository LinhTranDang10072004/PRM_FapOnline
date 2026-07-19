package com.example.demo.repository;

import com.example.demo.entity.UserRole;
import com.example.demo.entity.UserRoleId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRoleRepository extends JpaRepository<UserRole, UserRoleId> {

    List<UserRole> findByUserId(Integer userId);

    List<UserRole> findByRoleId(Integer roleId);

    long countByRoleId(Integer roleId);

    boolean existsByUserIdAndRoleId(Integer userId, Integer roleId);

    void deleteByUserId(Integer userId);

    void deleteByUserIdAndRoleId(Integer userId, Integer roleId);
}
