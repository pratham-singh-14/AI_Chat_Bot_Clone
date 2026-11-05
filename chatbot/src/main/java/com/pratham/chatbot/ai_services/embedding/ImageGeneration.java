package com.pratham.chatbot.ai_services.embedding;

import com.pratham.chatbot.service.MessageService;
import com.pratham.chatbot.service.OpenAiService;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@CrossOrigin("*")
public class ImageGeneration {

    private final OpenAiService openAiService;
    private final MessageService messageService;

    public ImageGeneration(OpenAiService openAiService, MessageService messageService) {
        this.openAiService = openAiService;
        this.messageService = messageService;
    }

    @PostMapping("/describe-edit-image")
    public Map<String, String> describeImage(
            @RequestParam String msg,
            @RequestParam MultipartFile file,
            @RequestParam(required = false) String conversationId
    ) throws IOException {

        byte[] imageBytes = file.getBytes();
        String mimeType = file.getContentType();

        String describe = openAiService.describeImage(msg, imageBytes, mimeType);

        if (conversationId != null && !conversationId.isBlank()) {
            messageService.persistUserMessage(conversationId, "[Image Uploaded] " + msg);
            messageService.persistAiMessage(conversationId, describe);
            messageService.ensureConversationTitle(conversationId, msg);
        }

        return Map.of("response", describe, "conversationId", conversationId == null ? "" : conversationId);
    }

    @PostMapping("/gen-image")
    public Map<String, String> genImage(
            @RequestParam String msg,
            @RequestParam(required = false) String conversationId
    ) {

        String url = openAiService.generateImage(msg);

        if (conversationId != null && !conversationId.isBlank()) {
            messageService.persistUserMessage(conversationId, msg);
            messageService.persistAiMessage(conversationId, url);
            messageService.ensureConversationTitle(conversationId, msg);
        }

        return Map.of("response", url, "conversationId", conversationId == null ? "" : conversationId);
    }

}
