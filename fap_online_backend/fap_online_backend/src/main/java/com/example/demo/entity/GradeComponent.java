package com.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "GradeComponents")
public class GradeComponent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "GradeComponentId", nullable = false)
    private Integer gradeComponentId;

    @Column(name = "ComponentName", nullable = false, length = 100)
    private String componentName;

    @Column(name = "Description", length = 255)
    private String description;

    @Column(name = "DefaultWeight", nullable = false)
    private BigDecimal defaultWeight;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive;

    public Integer getGradeComponentId() {
        return gradeComponentId;
    }

    public void setGradeComponentId(Integer gradeComponentId) {
        this.gradeComponentId = gradeComponentId;
    }

    public String getComponentName() {
        return componentName;
    }

    public void setComponentName(String componentName) {
        this.componentName = componentName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getDefaultWeight() {
        return defaultWeight;
    }

    public void setDefaultWeight(BigDecimal defaultWeight) {
        this.defaultWeight = defaultWeight;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

}
