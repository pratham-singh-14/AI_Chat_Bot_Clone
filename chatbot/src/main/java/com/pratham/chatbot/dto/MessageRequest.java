package com.pratham.chatbot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MessageRequest {
    private String conversationId;
    private String message;

    private String imageBase64;
    private String audioBase64;
    private String mimeType;
    private boolean generateAudio;
}
