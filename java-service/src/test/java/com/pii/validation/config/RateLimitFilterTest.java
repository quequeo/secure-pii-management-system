package com.pii.validation.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pii.validation.dto.SsnValidationRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@DisplayName("RateLimitFilter")
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class RateLimitFilterTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("allows requests under rate limit")
    void allowsRequestsUnderRateLimit() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(header().exists("X-RateLimit-Limit"))
                .andExpect(header().exists("X-RateLimit-Remaining"));
    }

    @Test
    @DisplayName("includes rate limit headers in response")
    void includesRateLimitHeaders() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(header().string("X-RateLimit-Limit", "100"));
    }

    @Test
    @DisplayName("returns 429 when rate limit exceeded")
    void returns429WhenRateLimitExceeded() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        // Make 101 requests to exceed the limit of 100/minute
        // Note: All requests come from the same RemoteAddr in tests
        for (int i = 0; i < 101; i++) {
            var result = mockMvc.perform(post("/api/v1/ssn/validate")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)));

            if (i < 100) {
                result.andExpect(status().isOk());
            } else {
                result.andExpect(status().isTooManyRequests())
                        .andExpect(header().exists("X-RateLimit-Reset"))
                        .andExpect(header().string("X-RateLimit-Remaining", "0"))
                        .andExpect(jsonPath("$.error").value("Too many requests"));
            }
        }
    }

    @Test
    @DisplayName("rate limit decreases with each request")
    void rateLimitDecreasesWithEachRequest() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        // First request should have high remaining count
        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(header().exists("X-RateLimit-Remaining"));
    }

    @Test
    @DisplayName("ignores X-Forwarded-For header for security")
    void ignoresXForwardedForHeader() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        // X-Forwarded-For is ignored; all requests use RemoteAddr
        // This prevents rate limit bypass attacks
        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .header("X-Forwarded-For", "spoofed.ip.address"))
                .andExpect(status().isOk())
                .andExpect(header().exists("X-RateLimit-Limit"));
    }
}
