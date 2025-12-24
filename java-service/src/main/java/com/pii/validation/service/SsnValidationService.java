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

    // SSA Standards: Invalid area numbers (first 3 digits)
    // Source: https://www.ssa.gov/employer/randomization.html
    private static final String INVALID_AREA_ALL_ZEROS = "000";
    private static final String INVALID_AREA_DEVIL_NUMBER = "666";
    
    // SSA Standards: Invalid group and serial numbers
    private static final String INVALID_GROUP_ALL_ZEROS = "00";
    private static final String INVALID_SERIAL_ALL_ZEROS = "0000";

    // Known public test SSNs that SSA has identified as invalid
    // These are different from the above rules - they're specific numbers to reject
    private static final Set<String> INVALID_SSNS = Set.of(
            "078-05-1120",  // Woolworth wallet SSN (famous public example)
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

        if (INVALID_AREA_ALL_ZEROS.equals(areaNumber)) {
            errors.add("Area number (first 3 digits) cannot be 000");
        }

        if (INVALID_AREA_DEVIL_NUMBER.equals(areaNumber)) {
            errors.add("Area number (first 3 digits) cannot be 666");
        }

        if (INVALID_GROUP_ALL_ZEROS.equals(groupNumber)) {
            errors.add("Group number (middle 2 digits) cannot be 00");
        }

        if (INVALID_SERIAL_ALL_ZEROS.equals(serialNumber)) {
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
