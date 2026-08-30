package com.dentassist.backend.conversation.dto;

import java.time.OffsetDateTime;

public record MessageDto(
        String id,
        String conversationId,
        String role,
        String content,
        OffsetDateTime createdAt
) {}
