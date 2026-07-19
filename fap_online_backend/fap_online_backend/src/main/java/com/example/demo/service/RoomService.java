package com.example.demo.service;

import com.example.demo.dto.RoomDTO;
import com.example.demo.dto.RoomRequest;

import java.util.List;

public interface RoomService {
    List<RoomDTO> getAllRooms();

    RoomDTO getRoomById(Integer roomId);

    RoomDTO createRoom(RoomRequest request);

    RoomDTO updateRoom(Integer roomId, RoomRequest request);

    void deleteRoom(Integer roomId);
}