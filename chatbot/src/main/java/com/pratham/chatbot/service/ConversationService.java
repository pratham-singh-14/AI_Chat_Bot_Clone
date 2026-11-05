package com.pratham.chatbot.service;

import com.pratham.chatbot.dto.ConversationListResponse;
import com.pratham.chatbot.dto.ConversationResponse;
import com.pratham.chatbot.dto.CoversationRequestDto;
import com.pratham.chatbot.entity.Conversation;
import com.pratham.chatbot.repository.ConversationRepo;
import com.pratham.chatbot.repository.MessageRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ConversationService {

    private final ConversationRepo conversationRepo;
    private final MessageRepository messageRepository;

    public ConversationService(ConversationRepo conversationRepo, MessageRepository messageRepository) {
        this.conversationRepo = conversationRepo;
        this.messageRepository = messageRepository;
    }

    public ConversationResponse createConversation(CoversationRequestDto request) {
        String conversationId = UUID.randomUUID().toString();
        Conversation conversation = Conversation.builder()
                .conversationId(conversationId)
                .clientId(request.getClientId())
                .title(null)
                .build();
        conversationRepo.save(conversation);
        return new ConversationResponse(conversationId);
    }

    public List<ConversationListResponse> fetchConversationList(String clientId) {
        List<Conversation> conversationList = conversationRepo.findByClientId(clientId);
        return conversationList.stream()
                .map(res -> {
                    ConversationListResponse conversationResponse = new ConversationListResponse();
                    conversationResponse.setConversationId(res.getConversationId());
                    conversationResponse.setTitle(res.getTitle());
                    return conversationResponse;
                }).toList();
    }

    public boolean deleteConversation(String conversationId) {
        if (conversationRepo.existsById(conversationId)) {
            messageRepository.deleteByConversationId(conversationId);
            conversationRepo.deleteById(conversationId);
            return true;
        }
        return false;
    }
}
