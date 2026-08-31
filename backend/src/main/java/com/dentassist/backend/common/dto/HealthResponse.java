package com.dentassist.backend.common.dto;

import java.util.Map;

public record HealthResponse(
        String status,
        String environment,
        Map<String, Object> checks
) {}
