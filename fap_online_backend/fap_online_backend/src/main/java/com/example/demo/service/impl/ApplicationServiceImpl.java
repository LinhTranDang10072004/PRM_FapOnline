package com.example.demo.service.impl;

import com.example.demo.dto.ApplicationDTO;
import com.example.demo.dto.ProcessApplicationRequest;
import com.example.demo.entity.*;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.*;
import com.example.demo.service.ApplicationService;
import com.example.demo.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * UC-18: Process Application
 *
 * Luồng chính:
 *  1. Staff xem danh sách đơn chờ xử lý (status filter)
 *  2. Staff chọn một đơn → xem chi tiết
 *  3. Staff chọn Approve hoặc Reject
 *  4. Staff nhập ghi chú / lý do
 *  5. Hệ thống cập nhật trạng thái đơn
 *  6. (Notification — phần mở rộng, hiện tại log thông tin xử lý)
 *
 * Business Rules:
 *  BR-A: Chỉ đơn có trạng thái Pending mới được xử lý.
 *  BR-B: Staff PHẢI nhập lý do khi từ chối (processNote không được trống).
 *  BR-C: Sau khi đơn được xử lý, trạng thái thay đổi thành Approved / Rejected.
 *  BR-D: Mỗi đơn chỉ được xử lý một lần (kiểm tra status != Pending).
 *  BR-E: Hệ thống lưu người xử lý (processedBy = staffUserId) + thời gian xử lý.
 *  BR-F: processedBy lấy từ JWT token của Staff đang đăng nhập (SecurityUtils).
 */
@Service
@RequiredArgsConstructor
public class ApplicationServiceImpl implements ApplicationService {

    private final ApplicationRepository applicationRepository;
    private final ApplicationTypeRepository applicationTypeRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;

    // ============================== READ ==============================

    /**
     * Bước 1 — Lấy danh sách đơn.
     * status = "Pending"  → chỉ đơn chờ xử lý.
     * status = null / ""  → toàn bộ đơn.
     */
    @Override
    public List<ApplicationDTO> getApplications(String status) {
        List<Application> applications = (status != null && !status.isBlank())
                ? applicationRepository.findByStatus(status)
                : applicationRepository.findAll();

        if (applications.isEmpty()) {
            return List.of();
        }

        // Batch-load Student + User để tránh N+1
        List<Integer> studentIds = applications.stream()
                .map(Application::getStudentId).distinct().collect(Collectors.toList());
        Map<Integer, Student> studentMap = studentIds.isEmpty()
                ? Map.of()
                : studentRepository.findAllByStudentIdIn(studentIds)
                        .stream().collect(Collectors.toMap(Student::getStudentId, s -> s));
        List<Integer> studentUserIds = studentMap.values().stream()
                .map(Student::getUserId).distinct().collect(Collectors.toList());
        Map<Integer, User> userMap = studentUserIds.isEmpty()
                ? Map.of()
                : userRepository.findAllById(studentUserIds)
                        .stream().collect(Collectors.toMap(User::getUserId, u -> u));

        // Batch-load ApplicationType
        List<Integer> typeIds = applications.stream()
                .map(Application::getApplicationTypeId).filter(Objects::nonNull)
                .distinct().collect(Collectors.toList());
        Map<Integer, ApplicationType> typeMap = typeIds.isEmpty()
                ? Map.of()
                : applicationTypeRepository.findAllById(typeIds)
                        .stream().collect(Collectors.toMap(ApplicationType::getApplicationTypeId, t -> t));

        // Batch-load User của Staff (processedBy)
        List<Integer> processorUserIds = applications.stream()
                .map(Application::getProcessedBy).filter(Objects::nonNull)
                .distinct().collect(Collectors.toList());
        Map<Integer, User> processorMap = processorUserIds.isEmpty()
                ? Map.of()
                : userRepository.findAllById(processorUserIds)
                        .stream().collect(Collectors.toMap(User::getUserId, u -> u));

        return applications.stream()
                .map(app -> mapToDTO(app, studentMap, userMap, typeMap, processorMap))
                .collect(Collectors.toList());
    }

    /**
     * Bước 2 — Xem chi tiết một đơn: loại đơn, nội dung, file đính kèm, thông tin sinh viên.
     */
    @Override
    public ApplicationDTO getApplicationById(Integer applicationId) {
        Application app = getApplicationOrThrow(applicationId);

        Student student = studentRepository.findById(app.getStudentId()).orElse(null);
        User studentUser = student != null
                ? userRepository.findById(student.getUserId()).orElse(null)
                : null;
        ApplicationType type = app.getApplicationTypeId() != null
                ? applicationTypeRepository.findById(app.getApplicationTypeId()).orElse(null)
                : null;
        User processorUser = app.getProcessedBy() != null
                ? userRepository.findById(app.getProcessedBy()).orElse(null)
                : null;

        return ApplicationDTO.builder()
                .applicationId(app.getApplicationId())
                .studentId(app.getStudentId())
                .studentCode(student != null ? student.getStudentCode() : "")
                .studentName(studentUser != null ? studentUser.getFullName() : "")
                .applicationTypeId(app.getApplicationTypeId())
                .applicationTypeName(type != null ? type.getTypeName() : "")
                .title(app.getTitle())
                .content(app.getContent())
                .relatedScheduleId(app.getRelatedScheduleId())
                .startDate(app.getStartDate())
                .endDate(app.getEndDate())
                .attachmentUrl(app.getAttachmentUrl())
                .status(app.getStatus())
                .processedBy(app.getProcessedBy())
                .processedByName(processorUser != null ? processorUser.getFullName() : "")
                .processedAt(app.getProcessedAt())
                .processNote(app.getProcessNote())
                .createdAt(app.getCreatedAt())
                .updatedAt(app.getUpdatedAt())
                .build();
    }

    // ============================== UC-18: Process Application ==============================

    /**
     * Bước 3–5 — Staff duyệt đơn (Approve).
     *
     * BR-A: Chỉ đơn Pending mới được xử lý.
     * BR-D: Đơn đã xử lý không được xử lý lại.
     * BR-E: Lưu processedBy (userId của Staff từ JWT) + processedAt.
     */
    @Override
    public ApplicationDTO approveApplication(Integer applicationId, ProcessApplicationRequest request) {
        Application app = getApplicationOrThrow(applicationId);

        // BR-A + BR-D: chỉ Pending mới được xử lý
        assertPending(app);

        // BR-E: lấy userId của Staff đang đăng nhập từ JWT
        Integer staffUserId = SecurityUtils.extractUserId();

        app.setStatus("Approved");
        app.setProcessedBy(staffUserId);
        app.setProcessedAt(LocalDateTime.now());
        app.setProcessNote(request.getProcessNote() != null ? request.getProcessNote().trim() : null);
        app.setUpdatedAt(LocalDateTime.now());

        applicationRepository.save(app);
        return getApplicationById(applicationId);
    }

    /**
     * Bước 3–5 — Staff từ chối đơn (Reject).
     *
     * BR-A: Chỉ đơn Pending mới được xử lý.
     * BR-B: Bắt buộc phải có lý do (processNote không được trống).
     * BR-D: Đơn đã xử lý không được xử lý lại.
     * BR-E: Lưu processedBy + processedAt.
     */
    @Override
    public ApplicationDTO rejectApplication(Integer applicationId, ProcessApplicationRequest request) {
        Application app = getApplicationOrThrow(applicationId);

        // BR-A + BR-D: chỉ Pending mới được xử lý
        assertPending(app);

        // BR-B: lý do từ chối bắt buộc
        if (request.getProcessNote() == null || request.getProcessNote().isBlank()) {
            throw new ValidationException("Phải nhập lý do khi từ chối đơn (processNote không được để trống)");
        }

        // BR-E: lấy userId của Staff đang đăng nhập từ JWT
        Integer staffUserId = SecurityUtils.extractUserId();

        app.setStatus("Rejected");
        app.setProcessedBy(staffUserId);
        app.setProcessedAt(LocalDateTime.now());
        app.setProcessNote(request.getProcessNote().trim());
        app.setUpdatedAt(LocalDateTime.now());

        applicationRepository.save(app);
        return getApplicationById(applicationId);
    }

    // ============================== Helpers ==============================

    private Application getApplicationOrThrow(Integer applicationId) {
        return applicationRepository.findById(applicationId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn từ với ID: " + applicationId));
    }

    /**
     * BR-A + BR-D: đảm bảo đơn đang ở trạng thái Pending.
     * Nếu không, ném ValidationException với thông báo rõ ràng.
     */
    private void assertPending(Application app) {
        if (!"Pending".equalsIgnoreCase(app.getStatus())) {
            throw new ValidationException(
                    "Đơn đã ở trạng thái '" + app.getStatus() + "', không thể xử lý lại. " +
                    "Chỉ đơn có trạng thái Pending mới được duyệt hoặc từ chối.");
        }
    }

    /**
     * Map Application entity → ApplicationDTO (batch version).
     */
    private ApplicationDTO mapToDTO(Application app,
                                    Map<Integer, Student> studentMap,
                                    Map<Integer, User> userMap,
                                    Map<Integer, ApplicationType> typeMap,
                                    Map<Integer, User> processorMap) {
        Student student = studentMap.get(app.getStudentId());
        User studentUser = student != null ? userMap.get(student.getUserId()) : null;
        ApplicationType type = typeMap.get(app.getApplicationTypeId());
        User processor = app.getProcessedBy() != null ? processorMap.get(app.getProcessedBy()) : null;

        return ApplicationDTO.builder()
                .applicationId(app.getApplicationId())
                .studentId(app.getStudentId())
                .studentCode(student != null ? student.getStudentCode() : "")
                .studentName(studentUser != null ? studentUser.getFullName() : "")
                .applicationTypeId(app.getApplicationTypeId())
                .applicationTypeName(type != null ? type.getTypeName() : "")
                .title(app.getTitle())
                .content(app.getContent())
                .relatedScheduleId(app.getRelatedScheduleId())
                .startDate(app.getStartDate())
                .endDate(app.getEndDate())
                .attachmentUrl(app.getAttachmentUrl())
                .status(app.getStatus())
                .processedBy(app.getProcessedBy())
                .processedByName(processor != null ? processor.getFullName() : "")
                .processedAt(app.getProcessedAt())
                .processNote(app.getProcessNote())
                .createdAt(app.getCreatedAt())
                .updatedAt(app.getUpdatedAt())
                .build();
    }
}
