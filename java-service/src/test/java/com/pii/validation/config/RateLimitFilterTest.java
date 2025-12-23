package com.pii.validation.config;

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
@DisplayName("RateLimitFilter")
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
        for (int i = 0; i < 101; i++) {
            var result = mockMvc.perform(post("/api/v1/ssn/validate")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request))
                            .header("X-Forwarded-For", "192.168.1.100"));

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
    @DisplayName("different IPs have separate rate limits")
    void differentIPsHaveSeparateRateLimits() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        // IP 1: Make 100 requests
        for (int i = 0; i < 100; i++) {
            mockMvc.perform(post("/api/v1/ssn/validate")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request))
                            .header("X-Forwarded-For", "192.168.1.1"))
                    .andExpect(status().isOk());
        }

        // IP 2: Should still be able to make requests
        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .header("X-Forwarded-For", "192.168.1.2"))
                .andExpect(status().isOk())
                .andExpect(header().exists("X-RateLimit-Remaining"));
    }

    @Test
    @DisplayName("uses RemoteAddr when X-Forwarded-For is not present")
    void usesRemoteAddrWhenXForwardedForNotPresent() throws Exception {
        SsnValidationRequest request = new SsnValidationRequest("123-45-6789");

        mockMvc.perform(post("/api/v1/ssn/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(header().exists("X-RateLimit-Limit"));
    }
}

