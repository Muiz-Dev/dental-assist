package com.dentassist.backend.conversation.dto;

import jakarta.validation.constraints.NotBlank;

public record AddMessageRequest(
        @NotBlank(message = "Content cannot be blank")
        String content
) {}
