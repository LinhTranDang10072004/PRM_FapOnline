package com.example.demo.security;

import com.example.demo.entity.Role;
import com.example.demo.entity.UserRole;
import com.example.demo.repository.RoleRepository;
import com.example.demo.repository.UserRoleRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

	private final JwtService jwtService;
	private final UserRoleRepository userRoleRepository;
	private final RoleRepository roleRepository;

	public JwtAuthenticationFilter(JwtService jwtService, UserRoleRepository userRoleRepository, RoleRepository roleRepository) {
		this.jwtService = jwtService;
		this.userRoleRepository = userRoleRepository;
		this.roleRepository = roleRepository;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		String authorizationHeader = request.getHeader("Authorization");

		if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
			String token = authorizationHeader.substring(7).trim();
			JwtService.TokenData tokenData = jwtService.parseToken(token);

			if (tokenData != null && tokenData.getUserId() != null && SecurityContextHolder.getContext().getAuthentication() == null) {
				List<GrantedAuthority> authorities = resolveAuthorities(tokenData.getUserId());
				AuthenticatedUser principal = new AuthenticatedUser(
						tokenData.getUserId(),
						tokenData.getUsername(),
						tokenData.getFullName()
				);

				Authentication authentication = new UsernamePasswordAuthenticationToken(
						principal,
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


	private List<GrantedAuthority> resolveAuthorities(Integer userId) {
		List<UserRole> userRoles = userRoleRepository.findByUserId(userId);
		if (userRoles.isEmpty()) {
			return List.of();
		}

		List<Integer> roleIds = userRoles.stream()
				.map(UserRole::getRoleId)
				.distinct()
				.collect(Collectors.toList());

		Map<Integer, Role> roleMap = roleRepository.findAllById(roleIds)
				.stream()
				.collect(Collectors.toMap(Role::getRoleId, r -> r));

		return roleIds.stream()
				.map(roleMap::get)
				.filter(role -> role != null && Boolean.TRUE.equals(role.getIsActive()))
				.map(role -> {
					String roleName = role.getRoleName().toUpperCase();
					if (!roleName.startsWith("ROLE_")) {
						roleName = "ROLE_" + roleName;
					}
					return (GrantedAuthority) new SimpleGrantedAuthority(roleName);
				})
				.collect(Collectors.toList());
	}
}
