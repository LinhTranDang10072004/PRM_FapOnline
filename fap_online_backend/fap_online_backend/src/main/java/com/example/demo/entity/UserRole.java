package com.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "UserRoles")
@IdClass(UserRoleId.class)
public class UserRole {

    @Id
    @Column(name = "UserId", nullable = false)
    private Integer userId;

    @Id
    @Column(name = "RoleId", nullable = false)
    private Integer roleId;

    @Column(name = "AssignedAt", nullable = false)
    private LocalDateTime assignedAt;

    @Column(name = "AssignedBy")
    private Integer assignedBy;

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    public Integer getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(Integer assignedBy) {
        this.assignedBy = assignedBy;
    }

}
