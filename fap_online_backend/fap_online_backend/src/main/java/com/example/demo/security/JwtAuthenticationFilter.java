package com.example.demo.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import com.example.demo.repository.ParentRepository;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

	private final JwtService jwtService;
	private final ParentRepository parentRepository;

	public JwtAuthenticationFilter(JwtService jwtService, ParentRepository parentRepository) {
		this.jwtService = jwtService;
		this.parentRepository = parentRepository;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		String authorizationHeader = request.getHeader("Authorization");

		if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
			String token = authorizationHeader.substring(7).trim();
			JwtService.TokenData tokenData = jwtService.parseToken(token);

			if (tokenData != null && tokenData.getUserId() != null && SecurityContextHolder.getContext().getAuthentication() == null) {
				List<SimpleGrantedAuthority> authorities = Collections.emptyList();
				if (parentRepository.findByUserId(tokenData.getUserId()).isPresent()) {
					authorities = List.of(new SimpleGrantedAuthority("ROLE_PARENT"));
				}
				Authentication authentication = new UsernamePasswordAuthenticationToken(
						tokenData.getUserId().toString(),
						null,
						authorities
				);
				((UsernamePasswordAuthenticationToken) authentication)
						.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
				SecurityContextHolder.getContext().setAuthentication(authentication);
			}
		}

		filterChain.doFilter(request, response);
	}
}
