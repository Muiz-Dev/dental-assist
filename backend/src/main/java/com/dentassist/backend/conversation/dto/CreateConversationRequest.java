package com.dentassist.backend.conversation.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateConversationRequest(
        String title,
        @NotBlank(message = "Initial message content cannot be blank")
        String initialMessage
) {}
