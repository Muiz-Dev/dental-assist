package com.dentassist.backend.conversation.dto;

import java.time.OffsetDateTime;
import java.util.List;

public record ConversationDto(
        String id,
        String title,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt,
        List<MessageDto> messages
) {}
