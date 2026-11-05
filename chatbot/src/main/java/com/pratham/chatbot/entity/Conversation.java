package com.pratham.chatbot.entity;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "conversations")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Conversation {

    @Id
    private String conversationId;

    private String clientId;

    private String title;
}
