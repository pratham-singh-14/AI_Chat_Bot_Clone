package com.pratham.chatbot.service;

import com.pratham.chatbot.dto.MessageListResponse;
import com.pratham.chatbot.dto.MessageRequest;
import com.pratham.chatbot.dto.MessageResponse;
import com.pratham.chatbot.entity.Conversation;
import com.pratham.chatbot.entity.Message;
import com.pratham.chatbot.repository.ConversationRepo;
import com.pratham.chatbot.repository.MessageRepository;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.util.List;

@Service
public class MessageService {

    private final MessageRepository messageRepository;
    private final ConversationRepo conversationRepo;
    private final ChatClient chatClient;
    private final ChatClient chatClientindependent;
    private final OpenAiService openAiService;

    public MessageService(
            MessageRepository messageRepository,
            ConversationRepo conversationRepo,
            @Qualifier("chatclient") ChatClient chatClient,
            @Qualifier("client") ChatClient chatClientindependent,
            OpenAiService openAiService
    ) {
        this.chatClient = chatClient;
        this.messageRepository = messageRepository;
        this.conversationRepo = conversationRepo;
        this.chatClientindependent = chatClientindependent;
        this.openAiService = openAiService;
    }

    public MessageResponse sendMessage(MessageRequest request) {
        String convId = request.getConversationId();
        String textMessage = request.getMessage() != null ? request.getMessage().trim() : "";

        if (request.getAudioBase64() != null && !request.getAudioBase64().isBlank()) {
            byte[] audioBytes = decodeBase64(request.getAudioBase64());
            String transcript = openAiService.transcribe(audioBytes, "voice.wav");

            String combinedPrompt = textMessage.isEmpty()
                    ? transcript
                    : textMessage + "\n[Voice Transcription]: " + transcript;

            persistUserMessage(convId, combinedPrompt, "audio", null, "data:audio/wav;base64," + request.getAudioBase64());

            ChatResponse chatResponse = chatClient.prompt(combinedPrompt)
                    .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, convId))
                    .call()
                    .chatResponse();

            String content = chatResponse.getResult().getOutput().getText();
            String audioReply = null;
            if (request.isGenerateAudio()) {
                byte[] ttsBytes = openAiService.textToSpeech(content);
                audioReply = "data:audio/wav;base64," + Base64.getEncoder().encodeToString(ttsBytes);
            }

            persistAiMessage(convId, content, "audio", null, audioReply);
            ensureConversationTitle(convId, combinedPrompt);

            return MessageResponse.builder()
                    .response(content)
                    .type("audio")
                    .audioUrl(audioReply)
                    .build();
        }

        if (request.getImageBase64() != null && !request.getImageBase64().isBlank()) {
            byte[] imageBytes = decodeBase64(request.getImageBase64());
            String mimeType = request.getMimeType() != null ? request.getMimeType() : "image/jpeg";
            String prompt = textMessage.isEmpty() ? "Describe this image in detail." : textMessage;

            persistUserMessage(convId, prompt, "image", "data:" + mimeType + ";base64," + request.getImageBase64(), null);

            String describe = openAiService.describeImage(prompt, imageBytes, mimeType);

            persistAiMessage(convId, describe, "image", null, null);
            ensureConversationTitle(convId, prompt);

            return MessageResponse.builder()
                    .response(describe)
                    .type("image")
                    .imageUrl("data:" + mimeType + ";base64," + request.getImageBase64())
                    .build();
        }

        if (isImageGenerationIntent(textMessage)) {
            persistUserMessage(convId, textMessage, "text", null, null);
            String imageUrl = openAiService.generateImage(textMessage);
            String reply = "Here is the image generated for: " + textMessage;
            persistAiMessage(convId, reply, "image", imageUrl, null);
            ensureConversationTitle(convId, textMessage);

            return MessageResponse.builder()
                    .response(reply)
                    .type("image")
                    .imageUrl(imageUrl)
                    .build();
        }

        persistUserMessage(convId, textMessage, "text", null, null);

        ChatResponse chatResponse = chatClient.prompt(textMessage)
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, convId))
                .call()
                .chatResponse();

        String content = chatResponse.getResult().getOutput().getText();
        String audioReply = null;
        if (request.isGenerateAudio()) {
            byte[] ttsBytes = openAiService.textToSpeech(content);
            audioReply = "data:audio/wav;base64," + Base64.getEncoder().encodeToString(ttsBytes);
        }

        persistAiMessage(convId, content, "text", null, audioReply);
        ensureConversationTitle(convId, textMessage);

        return MessageResponse.builder()
                .response(content)
                .type("text")
                .audioUrl(audioReply)
                .build();
    }

    private boolean isImageGenerationIntent(String text) {
        if (text == null) return false;
        String lower = text.toLowerCase().trim();
        return lower.startsWith("/image ")
                || lower.startsWith("generate image:")
                || lower.startsWith("generate an image of ")
                || lower.startsWith("create an image of ")
                || lower.startsWith("draw an image of ")
                || lower.startsWith("draw a picture of ");
    }

    private byte[] decodeBase64(String raw) {
        String data = raw;
        if (data.contains(",")) {
            data = data.substring(data.indexOf(",") + 1);
        }
        return Base64.getDecoder().decode(data);
    }

    public void persistUserMessage(String conversationId, String content) {
        persistUserMessage(conversationId, content, "text", null, null);
    }

    public void persistUserMessage(String conversationId, String content, String type, String imageUrl, String audioUrl) {
        Message msg = Message.builder()
                .message(content)
                .role("USER")
                .conversationId(conversationId)
                .type(type)
                .imageUrl(imageUrl)
                .audioUrl(audioUrl)
                .build();
        messageRepository.save(msg);
    }

    public void persistAiMessage(String conversationId, String content) {
        persistAiMessage(conversationId, content, "text", null, null);
    }

    public void persistAiMessage(String conversationId, String content, String type, String imageUrl, String audioUrl) {
        Message msg = Message.builder()
                .message(content)
                .role("AI")
                .conversationId(conversationId)
                .type(type)
                .imageUrl(imageUrl)
                .audioUrl(audioUrl)
                .build();
        messageRepository.save(msg);
    }

    public void ensureConversationTitle(String conversationId, String seedMessage) {
        Conversation conversation = conversationRepo.findById(conversationId).orElse(null);

        if (conversation != null && conversation.getTitle() == null) {
            String title = chatClientindependent.prompt()
                    .user("""
                  Generate a short title (maximum 6 words)
                  for this conversation.

                  User message:
                  %s

                  Return ONLY the title.
                  """.formatted(seedMessage))
                    .call()
                    .content();

            conversation.setTitle(title.trim().replaceAll("\"", ""));
            conversationRepo.save(conversation);
        }
    }

    public List<MessageListResponse> fetchMessages(String conversationId) {
        List<Message> list = messageRepository.findByConversationId(conversationId);
        return list.stream()
                .map(res -> MessageListResponse.builder()
                        .role(res.getRole())
                        .message(res.getMessage())
                        .type(res.getType() != null ? res.getType() : "text")
                        .imageUrl(res.getImageUrl())
                        .audioUrl(res.getAudioUrl())
                        .build()
                ).toList();
    }
}
