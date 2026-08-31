package com.dentassist.backend.common.dto;

import java.util.Map;

public record ErrorResponse(
        String code,
        String message,
        Map<String, String> details
) {}
