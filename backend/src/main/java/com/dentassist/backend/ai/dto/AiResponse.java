package com.dentassist.backend.ai.dto;

public record AiResponse(
        String content,
        String providerName,
        boolean isMock
) {}
