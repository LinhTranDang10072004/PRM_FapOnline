package com.example.demo.entity;

import java.io.Serializable;
import java.util.Objects;

public class ClassStudentId implements Serializable {

    private Integer classId;
    private Integer studentId;

    public ClassStudentId() {
    }

    public Integer getClassId() {
        return classId;
    }

    public void setClassId(Integer classId) {
        this.classId = classId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ClassStudentId that = (ClassStudentId) o;
        return Objects.equals(classId, that.classId) && Objects.equals(studentId, that.studentId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(classId, studentId);
    }
}
