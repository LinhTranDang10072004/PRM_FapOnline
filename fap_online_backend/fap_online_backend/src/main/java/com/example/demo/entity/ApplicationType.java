package com.example.demo.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "ApplicationTypes")
public class ApplicationType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ApplicationTypeId", nullable = false)
    private Integer applicationTypeId;

    @Column(name = "TypeName", nullable = false, length = 100)
    private String typeName;

    @Column(name = "Description", length = 255)
    private String description;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive;

    public Integer getApplicationTypeId() {
        return applicationTypeId;
    }

    public void setApplicationTypeId(Integer applicationTypeId) {
        this.applicationTypeId = applicationTypeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

}
