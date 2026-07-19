package com.example.demo.dto;

public class TeacherClassDTO {

    private Integer classId;

    private String classCode;

    private String className;

    private String subjectName;

    private Integer studentCount;

    private String status;
    public TeacherClassDTO() {
    }

    public TeacherClassDTO(
            Integer classId,
            String classCode,
            String className,
            String subjectName
    ) {

        this.classId = classId;
        this.classCode = classCode;
        this.className = className;
        this.subjectName = subjectName;

    }
    public TeacherClassDTO(
            Integer classId,
            String classCode,
            String className,
            String subjectName,
            Integer studentCount,
            String status) {

        this.classId = classId;
        this.classCode = classCode;
        this.className = className;
        this.subjectName = subjectName;
        this.studentCount = studentCount;
        this.status = status;

    }

    public String getStatus() {
        return status;
    }


    public void setStatus(String status) {
        this.status = status;
    }
    public Integer getClassId() {
        return classId;
    }


    public void setClassId(Integer classId) {
        this.classId = classId;
    }


    public String getClassCode() {
        return classCode;
    }


    public void setClassCode(String classCode) {
        this.classCode = classCode;
    }


    public String getClassName() {
        return className;
    }


    public void setClassName(String className) {
        this.className = className;
    }


    public String getSubjectName() {
        return subjectName;
    }


    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }


    public Integer getStudentCount() {
        return studentCount;
    }


    public void setStudentCount(Integer studentCount) {
        this.studentCount = studentCount;
    }
}