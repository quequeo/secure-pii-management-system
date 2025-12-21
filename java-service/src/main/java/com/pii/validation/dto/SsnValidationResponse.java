package com.pii.validation.dto;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class SsnValidationResponse {

    private boolean valid;
    private String ssn;
    private List<String> errors;

    public SsnValidationResponse() {
        this.errors = new ArrayList<>();
    }

    public SsnValidationResponse(boolean valid, String ssn) {
        this.valid = valid;
        this.ssn = ssn;
        this.errors = new ArrayList<>();
    }

    public SsnValidationResponse(boolean valid, String ssn, List<String> errors) {
        this.valid = valid;
        this.ssn = ssn;
        this.errors = errors != null ? errors : new ArrayList<>();
    }

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

    public String getSsn() {
        return ssn;
    }

    public void setSsn(String ssn) {
        this.ssn = ssn;
    }

    public List<String> getErrors() {
        return Collections.unmodifiableList(errors);
    }

    public void setErrors(List<String> errors) {
        this.errors = errors;
    }

    public void addError(String error) {
        this.errors.add(error);
    }

    public static SsnValidationResponse success(String ssn) {
        return new SsnValidationResponse(true, ssn);
    }

    public static SsnValidationResponse failure(String ssn, List<String> errors) {
        return new SsnValidationResponse(false, ssn, errors);
    }
}
