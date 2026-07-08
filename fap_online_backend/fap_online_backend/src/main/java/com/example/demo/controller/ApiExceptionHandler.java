package com.example.demo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class ApiExceptionHandler {

	@ExceptionHandler(ResponseStatusException.class)
	public ResponseEntity<Map<String, Object>> handleResponseStatus(ResponseStatusException ex) {
		Map<String, Object> body = new HashMap<>();
		body.put("message", ex.getReason() != null ? ex.getReason() : ex.getStatusCode().toString());
		body.put("status", ex.getStatusCode().value());
		return ResponseEntity.status(ex.getStatusCode()).body(body);
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex) {
		String message = ex.getBindingResult().getFieldErrors().stream()
				.findFirst()
				.map(error -> error.getDefaultMessage())
				.orElse("Du lieu khong hop le");

		Map<String, Object> body = new HashMap<>();
		body.put("message", message);
		body.put("status", HttpStatus.BAD_REQUEST.value());
		return ResponseEntity.badRequest().body(body);
	}
}
