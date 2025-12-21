package com.pii.validation.service;

import com.pii.validation.dto.SsnValidationResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

@Service
public class SsnValidationService {

    private static final Pattern SSN_FORMAT_PATTERN = Pattern.compile("^\\d{3}-\\d{2}-\\d{4}$");

    private static final Set<String> INVALID_SSNS = Set.of(
            "078-05-1120",  // Woolworth wallet SSN
            "219-09-9999",  // Used in advertisements
            "457-55-5462"   // Used in advertisements
    );

    public SsnValidationResponse validate(String ssn) {
        List<String> errors = new ArrayList<>();

        if (ssn == null || ssn.isBlank()) {
            errors.add("SSN is required");
            return SsnValidationResponse.failure(ssn, errors);
        }

        ssn = ssn.trim();

        if (!SSN_FORMAT_PATTERN.matcher(ssn).matches()) {
            errors.add("SSN must be in XXX-XX-XXXX format");
            return SsnValidationResponse.failure(ssn, errors);
        }

        String[] parts = ssn.split("-");
        String areaNumber = parts[0];
        String groupNumber = parts[1];
        String serialNumber = parts[2];

        if (areaNumber.equals("000")) {
            errors.add("Area number (first 3 digits) cannot be 000");
        }

        if (areaNumber.equals("666")) {
            errors.add("Area number (first 3 digits) cannot be 666");
        }

        if (groupNumber.equals("00")) {
            errors.add("Group number (middle 2 digits) cannot be 00");
        }

        if (serialNumber.equals("0000")) {
            errors.add("Serial number (last 4 digits) cannot be 0000");
        }

        if (INVALID_SSNS.contains(ssn)) {
            errors.add("This SSN is a known invalid test number");
        }

        if (errors.isEmpty()) {
            return SsnValidationResponse.success(ssn);
        }

        return SsnValidationResponse.failure(ssn, errors);
    }
}
