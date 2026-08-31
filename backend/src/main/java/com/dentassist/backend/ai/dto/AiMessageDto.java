package com.dentassist.backend.ai.dto;

import java.util.List;

public record AiMessageDto(
        String role,
        String content
) {}
