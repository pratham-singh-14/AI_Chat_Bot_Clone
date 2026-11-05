package com.pratham.chatbot.ai_services.embedding;

import com.pratham.chatbot.service.MessageService;
import com.pratham.chatbot.service.OpenAiService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@CrossOrigin("*")
public class Transcription {

    private final OpenAiService openAiService;
    private final MessageService messageService;

    public Transcription(OpenAiService openAiService, MessageService messageService) {
        this.openAiService = openAiService;
        this.messageService = messageService;
    }

    @PostMapping(value = "/text-to-speech", produces = {"audio/wav", "audio/mpeg"})
    public ResponseEntity<byte[]> ttsEndpoint(
            @RequestParam String text,
            @RequestParam(required = false) String conversationId
    ) {
        byte[] audioBytes = openAiService.textToSpeech(text);

        if (conversationId != null && !conversationId.isBlank()) {
            messageService.persistAiMessage(conversationId, "[Audio Response] " + text);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("audio/wav"))
                .body(audioBytes);
    }

    @PostMapping("/speech-to-text")
    public Map<String, String> sttEndpoint(
            @RequestParam MultipartFile file,
            @RequestParam(required = false) String conversationId
    ) throws IOException {

        byte[] audioBytes = file.getBytes();
        String originalFilename = file.getOriginalFilename();
        String transcript = openAiService.transcribe(audioBytes, originalFilename);

        if (conversationId != null && !conversationId.isBlank()) {
            messageService.persistUserMessage(conversationId, transcript);
            messageService.ensureConversationTitle(conversationId, transcript);
        }

        return Map.of("response", transcript, "conversationId", conversationId == null ? "" : conversationId);
    }

}
