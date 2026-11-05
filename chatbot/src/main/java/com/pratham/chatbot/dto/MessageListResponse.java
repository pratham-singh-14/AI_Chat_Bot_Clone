package com.pratham.chatbot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MessageListResponse {
    private String role;
    private String message;
    private String type;
    private String imageUrl;
    private String audioUrl;
}
