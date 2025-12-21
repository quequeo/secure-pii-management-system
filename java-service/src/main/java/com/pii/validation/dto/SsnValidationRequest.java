package com.pii.validation.dto;

import jakarta.validation.constraints.NotBlank;

public class SsnValidationRequest {

    @NotBlank(message = "SSN is required")
    private String ssn;

    public SsnValidationRequest() {
    }

    public SsnValidationRequest(String ssn) {
        this.ssn = ssn;
    }

    public String getSsn() {
        return ssn;
    }

    public void setSsn(String ssn) {
        this.ssn = ssn;
    }
}
