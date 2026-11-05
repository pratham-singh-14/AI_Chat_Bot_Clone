package com.pratham.chatbot.repository;

import com.pratham.chatbot.dto.ConversationResponse;
import com.pratham.chatbot.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ConversationRepo extends JpaRepository<Conversation,String> {

    List<Conversation> findByClientId(String clientId);
}
