package com.dentassist.backend.conversation.service;

import com.dentassist.backend.ai.dto.AiMessageDto;
import com.dentassist.backend.ai.dto.AiRequest;
import com.dentassist.backend.ai.dto.AiResponse;
import com.dentassist.backend.ai.service.AiProvider;
import com.dentassist.backend.conversation.domain.Conversation;
import com.dentassist.backend.conversation.domain.Message;
import com.dentassist.backend.conversation.dto.ConversationDto;
import com.dentassist.backend.conversation.dto.MessageDto;
import com.dentassist.backend.conversation.repository.ConversationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

@Service
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final AiProvider aiProvider;

    public ConversationService(ConversationRepository conversationRepository, AiProvider aiProvider) {
        this.conversationRepository = conversationRepository;
        this.aiProvider = aiProvider;
    }

    @Transactional
    public ConversationDto createConversation(String title, String initialMessage) {
        String convTitle = (title != null && !title.isBlank()) ? title : deriveTitle(initialMessage);
        Conversation conversation = new Conversation(convTitle);

        Message userMsg = new Message("USER", initialMessage);
        conversation.addMessage(userMsg);

        // Save initial user message to get accurate state
        conversation = conversationRepository.save(conversation);

        // Call AI Provider
        AiResponse aiResponse = getAiResponse(conversation, initialMessage);

        Message assistantMsg = new Message("ASSISTANT", aiResponse.content());
        conversation.addMessage(assistantMsg);

        conversation = conversationRepository.save(conversation);
        return toDto(conversation);
    }

    @Transactional(readOnly = true)
    public ConversationDto getConversation(String id) {
        Conversation conversation = conversationRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Conversation not found with id: " + id));
        return toDto(conversation);
    }

    @Transactional
    public ConversationDto addMessage(String conversationId, String content) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new NoSuchElementException("Conversation not found with id: " + conversationId));

        Message userMsg = new Message("USER", content);
        conversation.addMessage(userMsg);

        conversation = conversationRepository.save(conversation);

        // Call AI Provider
        AiResponse aiResponse = getAiResponse(conversation, content);

        Message assistantMsg = new Message("ASSISTANT", aiResponse.content());
        conversation.addMessage(assistantMsg);

        conversation = conversationRepository.save(conversation);
        return toDto(conversation);
    }

    private AiResponse getAiResponse(Conversation conversation, String newPrompt) {
        List<AiMessageDto> history = conversation.getMessages().stream()
                .map(m -> new AiMessageDto(m.getRole(), m.getContent()))
                .collect(Collectors.toList());

        AiRequest request = new AiRequest(conversation.getId(), history, newPrompt);
        return aiProvider.generate(request);
    }

    private String deriveTitle(String text) {
        if (text == null) return "Dental Consultation";
        String trimmed = text.trim();
        return trimmed.length() > 30 ? trimmed.substring(0, 30) + "..." : trimmed;
    }

    private ConversationDto toDto(Conversation conversation) {
        List<MessageDto> messageDtos = conversation.getMessages().stream()
                .map(m -> new MessageDto(m.getId(), conversation.getId(), m.getRole(), m.getContent(), m.getCreatedAt()))
                .collect(Collectors.toList());

        return new ConversationDto(
                conversation.getId(),
                conversation.getTitle(),
                conversation.getCreatedAt(),
                conversation.getUpdatedAt(),
                messageDtos
        );
    }
}
