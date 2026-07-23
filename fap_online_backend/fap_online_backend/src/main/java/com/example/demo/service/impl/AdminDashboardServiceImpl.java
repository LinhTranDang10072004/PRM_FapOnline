package com.example.demo.service.impl;

import com.example.demo.dto.AdminDashboardDTO;
import com.example.demo.dto.AdminSemesterDTO;
import com.example.demo.entity.Semester;
import com.example.demo.repository.ClassStudentRepository;
import com.example.demo.repository.SchoolClassRepository;
import com.example.demo.repository.SemesterRepository;
import com.example.demo.repository.StudentRepository;
import com.example.demo.repository.SubjectRepository;
import com.example.demo.repository.TeacherRepository;
import com.example.demo.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminDashboardServiceImpl implements AdminDashboardService {

    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectRepository subjectRepository;
    private final SemesterRepository semesterRepository;
    private final ClassStudentRepository classStudentRepository;

    @Override
    public AdminDashboardDTO getDashboard(String academicYear, String term) {
        List<Integer> semesterIds = resolveSemesterIds(academicYear, term);

        if (semesterIds == null) {
            return AdminDashboardDTO.builder()
                    .totalStudents(studentRepository.count())
                    .totalTeachers(teacherRepository.count())
                    .totalClasses(schoolClassRepository.count())
                    .totalSubjects(subjectRepository.count())
                    .build();
        }

        if (semesterIds.isEmpty()) {
            return AdminDashboardDTO.builder()
                    .totalStudents(0)
                    .totalTeachers(0)
                    .totalClasses(0)
                    .totalSubjects(0)
                    .build();
        }

        return AdminDashboardDTO.builder()
                .totalStudents(classStudentRepository.countDistinctStudentsBySemesterIds(semesterIds))
                .totalTeachers(schoolClassRepository.countDistinctTeachersBySemesterIds(semesterIds))
                .totalClasses(schoolClassRepository.countBySemesterIdIn(semesterIds))
                .totalSubjects(schoolClassRepository.countDistinctSubjectsBySemesterIds(semesterIds))
                .build();
    }

    @Override
    public List<AdminSemesterDTO> getSemesters() {
        return semesterRepository.findAllByOrderByStartDateDesc().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<String> getAcademicYears() {
        return semesterRepository.findDistinctAcademicYears();
    }

    /**
     * null  → không filter (toàn hệ thống)
     * empty → có filter nhưng không khớp học kỳ nào
     */
    private List<Integer> resolveSemesterIds(String academicYear, String term) {
        boolean hasYear = academicYear != null && !academicYear.isBlank();
        boolean hasTerm = term != null && !term.isBlank();

        if (!hasYear && !hasTerm) {
            return null;
        }

        List<Semester> semesters = hasYear
                ? semesterRepository.findByAcademicYearOrderByStartDateAsc(academicYear.trim())
                : semesterRepository.findAll();

        if (hasTerm) {
            String normalized = normalizeTerm(term);
            semesters = semesters.stream()
                    .filter(s -> normalized.equalsIgnoreCase(extractTerm(s)))
                    .collect(Collectors.toList());
        }

        return semesters.stream()
                .map(Semester::getSemesterId)
                .collect(Collectors.toList());
    }

    private AdminSemesterDTO toDto(Semester s) {
        return AdminSemesterDTO.builder()
                .semesterId(s.getSemesterId())
                .semesterCode(s.getSemesterCode())
                .semesterName(s.getSemesterName())
                .term(extractTerm(s))
                .academicYear(s.getAcademicYear())
                .startDate(s.getStartDate())
                .endDate(s.getEndDate())
                .status(s.getStatus())
                .build();
    }

    private String extractTerm(Semester s) {
        String name = s.getSemesterName() != null ? s.getSemesterName().trim() : "";
        if (!name.isEmpty()) {
            String first = name.split("\\s+")[0];
            String normalized = normalizeTerm(first);
            if (normalized != null) {
                return normalized;
            }
        }
        String code = s.getSemesterCode() != null ? s.getSemesterCode().toUpperCase(Locale.ROOT) : "";
        if (code.startsWith("FA")) return "Fall";
        if (code.startsWith("SP")) return "Spring";
        if (code.startsWith("SU")) return "Summer";
        return name;
    }

    private String normalizeTerm(String term) {
        if (term == null) return null;
        String t = term.trim().toLowerCase(Locale.ROOT);
        return switch (t) {
            case "fall", "fa" -> "Fall";
            case "spring", "sp" -> "Spring";
            case "summer", "su" -> "Summer";
            default -> term.trim();
        };
    }
}
