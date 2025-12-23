package com.pii.validation.controller;

import com.pii.validation.dto.SsnValidationRequest;
import com.pii.validation.dto.SsnValidationResponse;
import com.pii.validation.service.SsnValidationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/ssn")
public class SsnController {

    private final SsnValidationService validationService;

    public SsnController(SsnValidationService validationService) {
        this.validationService = validationService;
    }

    @PostMapping("/validate")
    public ResponseEntity<SsnValidationResponse> validate(@Valid @RequestBody SsnValidationRequest request) {
        String sanitizedSsn = sanitizeInput(request.getSsn());
        SsnValidationResponse response = validationService.validate(sanitizedSsn);

        if (response.isValid()) {
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.badRequest().body(response);
    }

    private String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        
        // First remove complete HTML tags (e.g., <script>), 
        // then remove any remaining isolated angle brackets (e.g., < or >)
        return input
            .replaceAll("<[^>]*>", "")
            .replaceAll("[<>]", "")
            .trim();
    }
}
