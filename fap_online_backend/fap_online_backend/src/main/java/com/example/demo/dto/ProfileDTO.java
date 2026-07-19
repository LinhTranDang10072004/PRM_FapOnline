package com.example.demo.dto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Null;
import java.time.LocalDate;

@Data 
@Builder 
@NoArgsConstructor 
@AllArgsConstructor 
public class ProfileDTO {
    @NotBlank(message = "Tên không được để trống")
    @Size(max = 100, message = "Tên không được vượt quá 100 ký tự")
    private String fullName;

    @Email(regexp = "^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$", message = "Email không hợp lệ")
    private String email;

    @Pattern(regexp = "^0[0-9]{9,10}$", message = "Số điện thoại không hợp lệ")
    private String phone;

    private LocalDate dateOfBirth;
    private String gender;
    private String address;
    private String avatarUrl;

    @Null(message = "Không được phép chỉnh sửa trường này")
    private String role;

    @Null(message = "Không được phép chỉnh sửa trường này")
    private String username;
}
