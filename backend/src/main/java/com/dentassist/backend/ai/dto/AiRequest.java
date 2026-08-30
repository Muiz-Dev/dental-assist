package com.dentassist.backend.ai.dto;

import java.util.List;

public record AiRequest(
        String conversationId,
        List<AiMessageDto> history,
        String prompt
) {}
