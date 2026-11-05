package com.pratham.chatbot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PdfChatRequest {
    private List<String> pdfIds;
    private String question;
    private String conversationId;
}
