package com.example.demo.security;

import com.example.demo.controller.ParentDashboardController;
import com.example.demo.service.ParentDashboardService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class ParentControllerSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ParentDashboardService parentDashboardService;

    @MockitoBean
    private JwtService jwtService;

    @MockitoBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Test
    public void testUnauthenticatedAccess_Returns401() throws Exception {
        mockMvc.perform(get("/api/parent/dashboard"))
                .andExpect(status().isUnauthorized()); // Or 403 depending on Spring Security version defaults if unauthorized
    }

    @Test
    @WithMockUser(username = "1", roles = {"STUDENT"})
    public void testNonParentRole_Returns403() throws Exception {
        mockMvc.perform(get("/api/parent/dashboard"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "1", roles = {"PARENT"})
    public void testParentRole_Returns200() throws Exception {
        // We mock the service to return a valid DTO or empty
        mockMvc.perform(get("/api/parent/dashboard"))
                .andExpect(status().isOk());
    }
}
