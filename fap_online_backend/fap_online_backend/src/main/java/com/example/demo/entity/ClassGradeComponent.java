package com.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "ClassGradeComponents")
public class ClassGradeComponent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ClassGradeComponentId", nullable = false)
    private Integer classGradeComponentId;

    @Column(name = "ClassId", nullable = false)
    private Integer classId;

    @Column(name = "GradeComponentId", nullable = false)
    private Integer gradeComponentId;

    @Column(name = "Weight", nullable = false)
    private BigDecimal weight;

    public Integer getClassGradeComponentId() {
        return classGradeComponentId;
    }

    public void setClassGradeComponentId(Integer classGradeComponentId) {
        this.classGradeComponentId = classGradeComponentId;
    }

    public Integer getClassId() {
        return classId;
    }

    public void setClassId(Integer classId) {
        this.classId = classId;
    }

    public Integer getGradeComponentId() {
        return gradeComponentId;
    }

    public void setGradeComponentId(Integer gradeComponentId) {
        this.gradeComponentId = gradeComponentId;
    }

    public BigDecimal getWeight() {
        return weight;
    }

    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }

}
