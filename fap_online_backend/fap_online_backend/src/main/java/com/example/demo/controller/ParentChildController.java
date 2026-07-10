package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.service.ParentChildService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/parent/children")
@RequiredArgsConstructor
@Tag(name = "Parent Child APIs", description = "Endpoints for parents to view their children's academic records")
@org.springframework.security.access.prepost.PreAuthorize("hasRole('PARENT')")
public class ParentChildController {

    private final ParentChildService parentChildService;
    @GetMapping
    @Operation(summary = "Get list of children", description = "Returns basic details of all children linked to the parent")
    public ResponseEntity<List<ChildDetailDTO>> getMyChildren() {
        return ResponseEntity.ok(parentChildService.getMyChildren());
    }

    @GetMapping("/{studentId}")
    @Operation(summary = "Get child profile detail", description = "Returns detailed profile of a specific child")
    public ResponseEntity<ChildDetailDTO> getChildDetail(
            @Parameter(description = "ID of the student") @PathVariable Integer studentId) {
        return ResponseEntity.ok(parentChildService.getChildDetail(studentId));
    }

    @GetMapping("/{studentId}/schedule")
    @Operation(summary = "Get child timetable", description = "Returns the weekly timetable for a specific child")
    public ResponseEntity<List<WeeklyTimetableDTO>> getChildTimetable(
            @Parameter(description = "ID of the student") @PathVariable Integer studentId,
            @Parameter(description = "Week date in YYYY-MM-DD format") @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) java.time.LocalDate week) {
        return ResponseEntity.ok(parentChildService.getChildTimetable(studentId, week));
    }

    @GetMapping("/{studentId}/attendance")
    @Operation(summary = "Get child attendance", description = "Returns the attendance report for a specific child")
    public ResponseEntity<List<AttendanceReportDTO>> getChildAttendance(
            @Parameter(description = "ID of the student") @PathVariable Integer studentId,
            @Parameter(description = "ID of the subject") @RequestParam(required = false) Integer subjectId,
            @Parameter(description = "ID of the semester") @RequestParam(required = false) Integer semesterId) {
        return ResponseEntity.ok(parentChildService.getChildAttendance(studentId, subjectId, semesterId));
    }

    @GetMapping("/{studentId}/grades")
    @Operation(summary = "Get child grades", description = "Returns the grade report for a specific child")
    public ResponseEntity<List<GradeReportDTO>> getChildGrades(
            @Parameter(description = "ID of the student") @PathVariable Integer studentId,
            @Parameter(description = "ID of the semester") @RequestParam(required = false) Integer semesterId) {
        return ResponseEntity.ok(parentChildService.getChildGrades(studentId, semesterId));
    }

    @GetMapping("/{studentId}/transcript")
    @Operation(summary = "Get child transcript", description = "Returns the academic transcript for a specific child")
    public ResponseEntity<List<TranscriptDTO>> getChildTranscript(
            @Parameter(description = "ID of the student") @PathVariable Integer studentId) {
        return ResponseEntity.ok(parentChildService.getChildTranscript(studentId));
    }

    @GetMapping("/{studentId}/fees")
    @Operation(summary = "Get child fees", description = "Returns the tuition and service fees for a specific child")
    public ResponseEntity<List<FeeDTO>> getChildFees(
            @Parameter(description = "ID of the student") @PathVariable Integer studentId,
            @Parameter(description = "ID of the semester") @RequestParam(required = false) Integer semesterId) {
        return ResponseEntity.ok(parentChildService.getChildFees(studentId, semesterId));
    }
}
