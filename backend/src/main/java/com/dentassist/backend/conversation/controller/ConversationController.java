package com.dentassist.backend.conversation.controller;

import com.dentassist.backend.conversation.dto.AddMessageRequest;
import com.dentassist.backend.conversation.dto.ConversationDto;
import com.dentassist.backend.conversation.dto.CreateConversationRequest;
import com.dentassist.backend.conversation.service.ConversationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/conversations")
public class ConversationController {

    private final ConversationService conversationService;

    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }

    @PostMapping
    public ResponseEntity<ConversationDto> createConversation(@Valid @RequestBody CreateConversationRequest request) {
        ConversationDto created = conversationService.createConversation(request.title(), request.initialMessage());
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ConversationDto> getConversation(@PathVariable String id) {
        ConversationDto conversation = conversationService.getConversation(id);
        return ResponseEntity.ok(conversation);
    }

    @PostMapping("/{id}/messages")
    public ResponseEntity<ConversationDto> addMessage(
            @PathVariable String id,
            @Valid @RequestBody AddMessageRequest request) {
        ConversationDto updated = conversationService.addMessage(id, request.content());
        return ResponseEntity.ok(updated);
    }
}
