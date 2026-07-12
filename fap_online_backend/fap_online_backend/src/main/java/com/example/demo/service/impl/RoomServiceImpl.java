package com.example.demo.service.impl;

import com.example.demo.dto.RoomDTO;
import com.example.demo.dto.RoomRequest;
import com.example.demo.entity.Room;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.exception.ValidationException;
import com.example.demo.repository.RoomRepository;
import com.example.demo.repository.ScheduleRepository;
import com.example.demo.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoomServiceImpl implements RoomService {

    private final RoomRepository roomRepository;
    private final ScheduleRepository scheduleRepository;

    @Override
    public List<RoomDTO> getAllRooms() {
        return roomRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public RoomDTO getRoomById(Integer roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy phòng học"));
        return mapToDTO(room);
    }

    @Override
    public RoomDTO createRoom(RoomRequest request) {
        String roomCode = request.getRoomCode().trim();

        if (roomRepository.existsByRoomCode(roomCode)) {
            throw new ValidationException("Mã phòng đã tồn tại");
        }

        Room room = new Room();
        room.setRoomCode(roomCode);
        room.setRoomName(request.getRoomName());
        room.setCapacity(request.getCapacity());
        room.setLocation(request.getLocation());
        room.setStatus(request.getStatus() != null ? request.getStatus() : "Active");

        return mapToDTO(roomRepository.save(room));
    }

    @Override
    public RoomDTO updateRoom(Integer roomId, RoomRequest request) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy phòng học"));

        String roomCode = request.getRoomCode().trim();
        if (roomRepository.existsByRoomCodeAndRoomIdNot(roomCode, roomId)) {
            throw new ValidationException("Mã phòng đã tồn tại");
        }

        room.setRoomCode(roomCode);
        room.setRoomName(request.getRoomName());
        room.setCapacity(request.getCapacity());
        room.setLocation(request.getLocation());
        if (request.getStatus() != null) {
            room.setStatus(request.getStatus());
        }

        return mapToDTO(roomRepository.save(room));
    }

    @Override
    public void deleteRoom(Integer roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy phòng học"));

        if (scheduleRepository.existsByRoomId(roomId)) {
            throw new ValidationException(
                    "Phòng đang được sử dụng trong lịch học, không thể xóa cứng. " +
                            "Hãy cập nhật trạng thái phòng sang Inactive thay vì xóa.");
        }

        roomRepository.delete(room);
    }

    private RoomDTO mapToDTO(Room room) {
        return RoomDTO.builder()
                .roomId(room.getRoomId())
                .roomCode(room.getRoomCode())
                .roomName(room.getRoomName())
                .capacity(room.getCapacity())
                .location(room.getLocation())
                .status(room.getStatus())
                .build();
    }
}