package com.pratham.chatbot.controller;

import com.pratham.chatbot.dto.CoversationRequestDto;
import com.pratham.chatbot.dto.MessageRequest;
import com.pratham.chatbot.service.ConversationService;
import com.pratham.chatbot.service.MessageService;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@CrossOrigin("*")
public class CommonController {

    private final ChatClient chatClient;
    private final ConversationService conversationService;
    private final MessageService messageService;

    public CommonController(@Qualifier("client") ChatClient chatclient,
                            ConversationService conversationService,
                            MessageService messageService) {
        this.chatClient = chatclient;
        this.conversationService = conversationService;
        this.messageService = messageService;
    }

    @GetMapping("/api/{msg}")
    public ResponseEntity<String> sendmsg(@PathVariable String msg) {
        String content = chatClient.prompt(msg).call().content();
        return ResponseEntity.ok(content);
    }

    @GetMapping("/conversations/{clientId}")
    public ResponseEntity<?> conversationHistory(@PathVariable String clientId) {
        if (clientId == null) {
            return ResponseEntity.badRequest().body(Map.of("msg", "ClientId is required"));
        }
        return ResponseEntity.ok().body(conversationService.fetchConversationList(clientId));
    }

    @GetMapping("/messages/{conversationId}")
    public ResponseEntity<?> messageList(@PathVariable String conversationId) {
        if (conversationId == null) {
            return ResponseEntity.badRequest().body(Map.of("msg", "conversationId is required"));
        }
        return ResponseEntity.ok().body(messageService.fetchMessages(conversationId));
    }

    @PostMapping("/conversations")
    public ResponseEntity<?> createNewConversation(@RequestBody CoversationRequestDto requestDto) {
        if (requestDto.getClientId() == null) {
            return ResponseEntity.badRequest().body(Map.of("msg", "ClientId not found"));
        }
        return ResponseEntity.ok(conversationService.createConversation(requestDto));
    }

    @DeleteMapping("/conversations/{conversationId}")
    public ResponseEntity<?> deleteConversation(@PathVariable String conversationId) {
        if (conversationId == null) {
            return ResponseEntity.badRequest().body(Map.of("msg", "conversationId is required"));
        }
        boolean deleted = conversationService.deleteConversation(conversationId);
        if (!deleted) {
            return ResponseEntity.status(404).body(Map.of("msg", "Conversation not found"));
        }
        return ResponseEntity.ok(Map.of("msg", "Conversation deleted successfully"));
    }

    @PostMapping("/messages")
    public ResponseEntity<?> sendMessage(@RequestBody MessageRequest messageRequest) {
        if (messageRequest.getConversationId() == null) {
            return ResponseEntity.badRequest().body(Map.of("msg", "ConversationId not found in this request"));
        }
        return ResponseEntity.ok().body(messageService.sendMessage(messageRequest));
    }

    @GetMapping("/session")
    public ResponseEntity<Map<String, String>> createSessionForNewUser() {
        String session = UUID.randomUUID().toString();
        Map<String, String> response = new HashMap<>();
        response.put("clientId", session);
        return ResponseEntity.ok(response);
    }
}
