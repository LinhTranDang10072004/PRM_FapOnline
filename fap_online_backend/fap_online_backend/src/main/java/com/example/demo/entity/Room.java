package com.example.demo.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "Rooms")
public class Room {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RoomId", nullable = false)
    private Integer roomId;

    @Column(name = "RoomCode", nullable = false, length = 30)
    private String roomCode;

    @Column(name = "RoomName", nullable = false, length = 100)
    private String roomName;

    @Column(name = "Capacity", nullable = false)
    private Integer capacity;

    @Column(name = "Location", length = 150)
    private String location;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public String getRoomCode() {
        return roomCode;
    }

    public void setRoomCode(String roomCode) {
        this.roomCode = roomCode;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public Integer getCapacity() {
        return capacity;
    }

    public void setCapacity(Integer capacity) {
        this.capacity = capacity;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

}
