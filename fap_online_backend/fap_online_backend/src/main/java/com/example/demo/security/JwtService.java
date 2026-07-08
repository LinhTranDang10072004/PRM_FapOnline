package com.example.demo.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

@Component
public class JwtService {

	private final SecretKey signingKey;
	private final long expirationMs;

	public JwtService(
			@Value("${jwt.secret}") String secret,
			@Value("${jwt.expiration}") long expirationMs) {
		this.signingKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
		this.expirationMs = expirationMs;
	}

	public String generateToken(Integer userId, String username, String fullName) {
		Date now = new Date();
		Date expiry = new Date(now.getTime() + expirationMs);

		return Jwts.builder()
				.subject(username)
				.claim("userId", userId)
				.claim("fullName", fullName)
				.issuedAt(now)
				.expiration(expiry)
				.signWith(signingKey)
				.compact();
	}

	public TokenData parseToken(String token) {
		if (token == null || token.isBlank()) {
			return null;
		}

		try {
			Claims claims = Jwts.parser()
					.verifyWith(signingKey)
					.build()
					.parseSignedClaims(token)
					.getPayload();

			TokenData data = new TokenData();
			data.setUserId(claims.get("userId", Integer.class));
			data.setUsername(claims.getSubject());
			data.setFullName(claims.get("fullName", String.class));
			if (claims.getIssuedAt() != null) {
				data.setIssuedAt(LocalDateTime.ofInstant(claims.getIssuedAt().toInstant(), ZoneId.systemDefault()));
			}
			return data;
		} catch (ExpiredJwtException ex) {
			return null;
		} catch (Exception ex) {
			return null;
		}
	}

	public static class TokenData {
		private Integer userId;
		private String username;
		private String fullName;
		private LocalDateTime issuedAt;

		public Integer getUserId() {
			return userId;
		}

		public void setUserId(Integer userId) {
			this.userId = userId;
		}

		public String getUsername() {
			return username;
		}

		public void setUsername(String username) {
			this.username = username;
		}

		public String getFullName() {
			return fullName;
		}

		public void setFullName(String fullName) {
			this.fullName = fullName;
		}

		public LocalDateTime getIssuedAt() {
			return issuedAt;
		}

		public void setIssuedAt(LocalDateTime issuedAt) {
			this.issuedAt = issuedAt;
		}
	}
}
