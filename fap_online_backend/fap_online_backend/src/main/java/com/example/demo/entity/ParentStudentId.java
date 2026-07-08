package com.example.demo.entity;

import java.io.Serializable;
import java.util.Objects;

public class ParentStudentId implements Serializable {

    private Integer parentId;
    private Integer studentId;

    public ParentStudentId() {
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
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
        ParentStudentId that = (ParentStudentId) o;
        return Objects.equals(parentId, that.parentId) && Objects.equals(studentId, that.studentId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(parentId, studentId);
    }
}
