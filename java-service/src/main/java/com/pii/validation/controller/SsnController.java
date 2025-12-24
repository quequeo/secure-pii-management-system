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
        SsnValidationResponse response = validationService.validate(request.getSsn());

        if (response.isValid()) {
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.badRequest().body(response);
    }
}
