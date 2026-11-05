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
public class MessageResponse {
    private String response;
    private String type;
    private String imageUrl;
    private String audioUrl;
    private List<SourceCitation> sources;

    public MessageResponse(String response) {
        this.response = response;
        this.type = "text";
    }
}
