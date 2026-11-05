package com.pratham.chatbot.repository;

import com.pratham.chatbot.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByConversationId(String conversationId);

    @Modifying
    @Transactional
    void deleteByConversationId(String conversationId);
}
