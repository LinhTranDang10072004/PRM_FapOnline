package com.example.demo.service.impl;

import com.example.demo.dto.AdminUserCreateRequest;
import com.example.demo.dto.AdminUserDTO;
import com.example.demo.dto.AdminUserUpdateRequest;
import com.example.demo.entity.*;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.*;
import com.example.demo.service.AdminUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * UC: Manage Users (Admin)
 * Thêm / sửa / xóa (soft) / khóa / mở khóa tài khoản.
 * Đồng thời gán Role + tạo profile tương ứng (Student, Teacher, Staff, Parent).
 */
@Service
@RequiredArgsConstructor
public class AdminUserServiceImpl implements AdminUserService {

    /** Trạng thái tài khoản chuẩn (khớp AuthService login: chỉ Active mới đăng nhập được). */
    private static final String STATUS_ACTIVE = "Active";
    private static final String STATUS_LOCKED = "Locked";
    private static final String STATUS_DELETED = "Deleted";

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final StaffRepository staffRepository;
    private final ParentRepository parentRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Danh sách user kèm filter:
     * - role: tên role (ADMIN, STUDENT, ...) — khớp bất kỳ role nào của user
     * - status: Active / Locked
     * - q: tìm trong username, fullName, email
     * User đã soft-delete (Deleted) không trả về.
     */
    @Override
    public List<AdminUserDTO> getUsers(String role, String status, String q) {
        String roleFilter = normalize(role);
        String statusFilter = normalize(status);
        String query = q == null ? "" : q.trim().toLowerCase(Locale.ROOT);

        return userRepository.findAll().stream()
                // Ẩn user đã xóa mềm
                .filter(u -> !STATUS_DELETED.equalsIgnoreCase(u.getStatus()))
                .map(this::toDto)
                // Filter theo role (nếu có)
                .filter(dto -> roleFilter.isEmpty()
                        || dto.getRoles().stream().anyMatch(r -> r.equalsIgnoreCase(roleFilter)))
                // Filter theo trạng thái (nếu có)
                .filter(dto -> statusFilter.isEmpty()
                        || (dto.getStatus() != null && dto.getStatus().equalsIgnoreCase(statusFilter)))
                // Tìm kiếm text
                .filter(dto -> query.isEmpty()
                        || contains(dto.getUsername(), query)
                        || contains(dto.getFullName(), query)
                        || contains(dto.getEmail(), query))
                .collect(Collectors.toList());
    }

    /** Chi tiết 1 user (không trả user Deleted). */
    @Override
    public AdminUserDTO getUserById(Integer userId) {
        return toDto(findUser(userId));
    }

    /**
     * Tạo tài khoản mới:
     * 1) Validate username/email trùng
     * 2) Hash password + lưu Users
     * 3) Gán 1 role vào UserRoles
     * 4) Tạo profile bảng riêng theo role (trừ ADMIN)
     */
    @Override
    @Transactional
    public AdminUserDTO createUser(AdminUserCreateRequest request) {
        String username = request.getUsername().trim();
        String email = request.getEmail().trim();
        String roleName = request.getRoleName().trim().toUpperCase(Locale.ROOT);

        if (userRepository.existsByUsername(username)) {
            throw new ValidationException("Username đã tồn tại");
        }
        if (userRepository.existsByEmail(email)) {
            throw new ValidationException("Email đã tồn tại");
        }

        Role role = roleRepository.findByRoleNameIgnoreCase(roleName)
                .orElseThrow(() -> new ValidationException("Role không hợp lệ: " + roleName));

        LocalDateTime now = LocalDateTime.now();
        User user = new User();
        user.setUsername(username);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName().trim());
        user.setEmail(email);
        user.setPhone(blankToNull(request.getPhone()));
        user.setGender(blankToNull(request.getGender()));
        user.setAddress(blankToNull(request.getAddress()));
        user.setStatus(STATUS_ACTIVE);
        user.setCreatedAt(now);
        user = userRepository.save(user);

        // Gán role cho user
        UserRole userRole = new UserRole();
        userRole.setUserId(user.getUserId());
        userRole.setRoleId(role.getRoleId());
        userRole.setAssignedAt(now);
        userRoleRepository.save(userRole);

        // Tạo hồ sơ Student/Teacher/Staff/Parent nếu cần
        createProfileIfNeeded(user.getUserId(), roleName, request.getProfileCode(), now);
        return toDto(user);
    }

    /**
     * Cập nhật thông tin cá nhân / password / role.
     * Đổi role: xóa hết UserRoles cũ → gán role mới → tạo profile nếu chưa có.
     */
    @Override
    @Transactional
    public AdminUserDTO updateUser(Integer userId, AdminUserUpdateRequest request) {
        User user = findUser(userId);

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getEmail() != null && !request.getEmail().isBlank()) {
            String email = request.getEmail().trim();
            if (userRepository.existsByEmailAndUserIdNot(email, userId)) {
                throw new ValidationException("Email đã được dùng bởi tài khoản khác");
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
        // Chỉ đổi password khi client gửi giá trị mới
        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }

        // Đổi role chính (replace toàn bộ roles hiện tại)
        if (request.getRoleName() != null && !request.getRoleName().isBlank()) {
            String roleName = request.getRoleName().trim().toUpperCase(Locale.ROOT);
            Role role = roleRepository.findByRoleNameIgnoreCase(roleName)
                    .orElseThrow(() -> new ValidationException("Role không hợp lệ: " + roleName));
            userRoleRepository.deleteByUserId(userId);
            UserRole userRole = new UserRole();
            userRole.setUserId(userId);
            userRole.setRoleId(role.getRoleId());
            userRole.setAssignedAt(LocalDateTime.now());
            userRoleRepository.save(userRole);
            ensureProfileExists(userId, roleName);
        }

        user.setUpdatedAt(LocalDateTime.now());
        return toDto(userRepository.save(user));
    }

    /**
     * Soft delete: đặt status = Deleted (không xóa cứng để tránh lỗi FK).
     * User Deleted không còn xuất hiện trong getUsers / getUserById.
     */
    @Override
    @Transactional
    public void deleteUser(Integer userId) {
        User user = findUser(userId);
        user.setStatus(STATUS_DELETED);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    /** Khóa tài khoản → không đăng nhập được (AuthService chỉ cho phép Active). */
    @Override
    @Transactional
    public AdminUserDTO lockUser(Integer userId) {
        User user = findUser(userId);
        if (STATUS_DELETED.equalsIgnoreCase(user.getStatus())) {
            throw new ValidationException("Tài khoản đã bị xóa");
        }
        user.setStatus(STATUS_LOCKED);
        user.setUpdatedAt(LocalDateTime.now());
        return toDto(userRepository.save(user));
    }

    /** Mở khóa → status Active. */
    @Override
    @Transactional
    public AdminUserDTO unlockUser(Integer userId) {
        User user = findUser(userId);
        if (STATUS_DELETED.equalsIgnoreCase(user.getStatus())) {
            throw new ValidationException("Tài khoản đã bị xóa, không thể mở khóa");
        }
        user.setStatus(STATUS_ACTIVE);
        user.setUpdatedAt(LocalDateTime.now());
        return toDto(userRepository.save(user));
    }

    /** Tìm user; coi Deleted như không tồn tại. */
    private User findUser(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy user #" + userId));
        if (STATUS_DELETED.equalsIgnoreCase(user.getStatus())) {
            throw new ResourceNotFoundException("Không tìm thấy user #" + userId);
        }
        return user;
    }

    /**
     * Tạo hồ sơ theo role sau khi tạo user.
     * profileCode: mã SV/TC/ST/PH; để trống thì tự sinh (VD: SV12).
     */
    private void createProfileIfNeeded(Integer userId, String roleName, String profileCode, LocalDateTime now) {
        String code = (profileCode == null || profileCode.isBlank())
                ? defaultProfileCode(roleName, userId)
                : profileCode.trim();

        switch (roleName) {
            case "STUDENT" -> {
                Student s = new Student();
                s.setUserId(userId);
                s.setStudentCode(code);
                s.setMajor("Software Engineering");
                s.setEnrollmentYear(LocalDateTime.now().getYear());
                s.setAcademicStatus("STUDYING");
                s.setCreatedAt(now);
                try {
                    studentRepository.save(s);
                } catch (DataIntegrityViolationException e) {
                    throw new ValidationException("Mã sinh viên đã tồn tại");
                }
            }
            case "TEACHER" -> {
                Teacher t = new Teacher();
                t.setUserId(userId);
                t.setTeacherCode(code);
                t.setDepartment("Công nghệ phần mềm");
                t.setCreatedAt(now);
                try {
                    teacherRepository.save(t);
                } catch (DataIntegrityViolationException e) {
                    throw new ValidationException("Mã giáo viên đã tồn tại");
                }
            }
            case "STAFF" -> {
                Staff st = new Staff();
                st.setUserId(userId);
                st.setStaffCode(code);
                st.setDepartment("Phòng Đào tạo");
                st.setCreatedAt(now);
                try {
                    staffRepository.save(st);
                } catch (DataIntegrityViolationException e) {
                    throw new ValidationException("Mã staff đã tồn tại");
                }
            }
            case "PARENT" -> {
                Parent p = new Parent();
                p.setUserId(userId);
                p.setParentCode(code);
                p.setCreatedAt(now);
                try {
                    parentRepository.save(p);
                } catch (DataIntegrityViolationException e) {
                    throw new ValidationException("Mã phụ huynh đã tồn tại");
                }
            }
            default -> {
                // ADMIN: không có bảng profile riêng
            }
        }
    }

    /** Khi đổi role: nếu chưa có profile tương ứng thì tạo mới. */
    private void ensureProfileExists(Integer userId, String roleName) {
        boolean exists = switch (roleName) {
            case "STUDENT" -> studentRepository.findByUserId(userId).isPresent();
            case "TEACHER" -> teacherRepository.findByUserId(userId).isPresent();
            case "STAFF" -> staffRepository.findByUserId(userId).isPresent();
            case "PARENT" -> parentRepository.findByUserId(userId).isPresent();
            default -> true;
        };
        if (!exists) {
            createProfileIfNeeded(userId, roleName, null, LocalDateTime.now());
        }
    }

    /** Mã hồ sơ mặc định: SV{userId}, TC{userId}, ... */
    private String defaultProfileCode(String roleName, Integer userId) {
        String prefix = switch (roleName) {
            case "STUDENT" -> "SV";
            case "TEACHER" -> "TC";
            case "STAFF" -> "ST";
            case "PARENT" -> "PH";
            default -> "US";
        };
        return prefix + userId;
    }

    /**
     * Map User → AdminUserDTO (kèm danh sách role từ UserRoles).
     * primaryRole = role đầu tiên trong list.
     */
    private AdminUserDTO toDto(User user) {
        List<UserRole> userRoles = userRoleRepository.findByUserId(user.getUserId());
        List<String> roles = userRoles.stream()
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

    private static boolean contains(String value, String query) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(query);
    }

    private static String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private static String blankToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
