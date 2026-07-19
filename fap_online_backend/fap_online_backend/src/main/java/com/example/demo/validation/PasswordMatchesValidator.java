package com.example.demo.validation;

import com.example.demo.dto.ChangePasswordRequest;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class PasswordMatchesValidator implements ConstraintValidator<PasswordMatches, ChangePasswordRequest> {
    @Override
    public boolean isValid(ChangePasswordRequest request, ConstraintValidatorContext context) {
        if (request == null || request.getNewPassword() == null || request.getConfirmPassword() == null) {
            return true; // Let @NotBlank handle nulls
        }
        
        boolean isValid = request.getNewPassword().equals(request.getConfirmPassword());
        if (!isValid) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate(context.getDefaultConstraintMessageTemplate())
                   .addPropertyNode("confirmPassword").addConstraintViolation();
        }
        return isValid;
    }
}
