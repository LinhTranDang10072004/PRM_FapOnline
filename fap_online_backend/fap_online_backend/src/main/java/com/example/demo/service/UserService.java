package com.example.demo.service;
import com.example.demo.dto.ProfileDto;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public ProfileDto getProfile(String username) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isPresent()) {
            User u = userOpt.get();
            ProfileDto dto = new ProfileDto();
            dto.setUsername(u.getUsername());
            dto.setFullName(u.getFullName());
            dto.setEmail(u.getEmail());
            dto.setPhone(u.getPhone());
            dto.setDateOfBirth(u.getDateOfBirth());
            dto.setGender(u.getGender());
            dto.setAddress(u.getAddress());
            dto.setAvatarUrl(u.getAvatarUrl());
            return dto;
        }
        return null;
    }

    public boolean updateProfile(String username, ProfileDto dto) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isPresent()) {
            User u = userOpt.get();
            u.setFullName(dto.getFullName());
            u.setPhone(dto.getPhone());
            u.setAddress(dto.getAddress());
            userRepository.save(u);
            return true;
        }
        return false;
    }
}
