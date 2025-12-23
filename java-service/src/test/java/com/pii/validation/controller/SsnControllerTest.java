package com.pii.validation.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pii.validation.dto.SsnValidationRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@DisplayName("SsnController")
class SsnControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("POST /api/v1/ssn/validate returns 200 for valid SSN")
    void returnsOkForValidSsn() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid").value(true))
                .andExpect(jsonPath("$.ssn").value("123-45-6789"));
    }

    @Test
    @DisplayName("POST /api/v1/ssn/validate returns 400 for invalid SSN")
    void returnsBadRequestForInvalidSsn() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("000-45-6789");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.valid").value(false))
                .andExpect(jsonPath("$.errors").isArray());
    }

    @Test
    @DisplayName("POST /api/v1/ssn/validate returns 400 for missing SSN")
    void returnsBadRequestForMissingSsn() throws Exception {
        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /api/v1/ssn/validate rejects SSN with HTML script tags")
    void rejectsHtmlScriptTags() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789<script>alert('xss')</script>");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.valid").value(false));
    }

    @Test
    @DisplayName("POST /api/v1/ssn/validate rejects SSN with HTML tags")
    void rejectsHtmlTags() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789<b>test</b>");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.valid").value(false));
    }

    @Test
    @DisplayName("POST /api/v1/ssn/validate trims whitespace")
    void trimsWhitespace() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("  123-45-6789  ");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid").value(true))
                .andExpect(jsonPath("$.ssn").value("123-45-6789"));
    }

    @Test
    @DisplayName("POST /api/v1/ssn/validate removes angle brackets")
    void removesAngleBrackets() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123<45>6789");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.valid").value(false));
    }
}
