package com.pii.validation.service;

import com.pii.validation.dto.SsnValidationResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("SsnValidationService")
class SsnValidationServiceTest {

    private SsnValidationService service;

    @BeforeEach
    void setUp() {
        service = new SsnValidationService();
    }

    @Nested
    @DisplayName("valid SSNs")
    class ValidSsns {

        @Test
        @DisplayName("accepts a valid SSN")
        void acceptsValidSsn() {
            SsnValidationResponse response = service.validate("123-45-6789");

            assertTrue(response.isValid());
            assertTrue(response.getErrors().isEmpty());
        }

        @Test
        @DisplayName("accepts SSN in 900-999 range (ITIN)")
        void acceptsItinRange() {
            SsnValidationResponse response = service.validate("900-45-6789");

            assertTrue(response.isValid());
        }

        @Test
        @DisplayName("trims whitespace")
        void trimsWhitespace() {
            SsnValidationResponse response = service.validate("  123-45-6789  ");

            assertTrue(response.isValid());
        }
    }

    @Nested
    @DisplayName("null and blank")
    class NullAndBlank {

        @Test
        @DisplayName("rejects null SSN")
        void rejectsNull() {
            SsnValidationResponse response = service.validate(null);

            assertFalse(response.isValid());
            assertTrue(response.getErrors().contains("SSN is required"));
        }

        @Test
        @DisplayName("rejects blank SSN")
        void rejectsBlank() {
            SsnValidationResponse response = service.validate("   ");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().contains("SSN is required"));
        }
    }

    @Nested
    @DisplayName("format validation")
    class FormatValidation {

        @Test
        @DisplayName("rejects SSN without dashes")
        void rejectsWithoutDashes() {
            SsnValidationResponse response = service.validate("123456789");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().contains("SSN must be in XXX-XX-XXXX format"));
        }

        @Test
        @DisplayName("rejects SSN with wrong format")
        void rejectsWrongFormat() {
            SsnValidationResponse response = service.validate("12-345-6789");

            assertFalse(response.isValid());
        }
    }

    @Nested
    @DisplayName("area number validation")
    class AreaNumberValidation {

        @Test
        @DisplayName("rejects area number 000")
        void rejectsArea000() {
            SsnValidationResponse response = service.validate("000-45-6789");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().stream()
                    .anyMatch(e -> e.contains("000")));
        }

        @Test
        @DisplayName("rejects area number 666")
        void rejectsArea666() {
            SsnValidationResponse response = service.validate("666-45-6789");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().stream()
                    .anyMatch(e -> e.contains("666")));
        }
    }

    @Nested
    @DisplayName("group number validation")
    class GroupNumberValidation {

        @Test
        @DisplayName("rejects group number 00")
        void rejectsGroup00() {
            SsnValidationResponse response = service.validate("123-00-6789");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().stream()
                    .anyMatch(e -> e.contains("00")));
        }
    }

    @Nested
    @DisplayName("serial number validation")
    class SerialNumberValidation {

        @Test
        @DisplayName("rejects serial number 0000")
        void rejectsSerial0000() {
            SsnValidationResponse response = service.validate("123-45-0000");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().stream()
                    .anyMatch(e -> e.contains("0000")));
        }
    }

    @Nested
    @DisplayName("known invalid SSNs")
    class KnownInvalidSsns {

        @Test
        @DisplayName("rejects Woolworth SSN")
        void rejectsWoolworth() {
            SsnValidationResponse response = service.validate("078-05-1120");

            assertFalse(response.isValid());
            assertTrue(response.getErrors().stream()
                    .anyMatch(e -> e.contains("known invalid")));
        }

        @Test
        @DisplayName("rejects advertisement SSN 219-09-9999")
        void rejectsAdvertisement1() {
            SsnValidationResponse response = service.validate("219-09-9999");

            assertFalse(response.isValid());
        }

        @Test
        @DisplayName("rejects advertisement SSN 457-55-5462")
        void rejectsAdvertisement2() {
            SsnValidationResponse response = service.validate("457-55-5462");

            assertFalse(response.isValid());
        }
    }
}
