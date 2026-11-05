package com.pratham.chatbot.service;

import org.springframework.ai.audio.transcription.AudioTranscriptionPrompt;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.image.ImageModel;
import org.springframework.ai.image.ImagePrompt;
import org.springframework.ai.image.ImageResponse;
import org.springframework.ai.openai.OpenAiAudioSpeechModel;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.stereotype.Service;
import org.springframework.util.MimeType;
import org.springframework.util.MimeTypeUtils;

import java.util.List;

@Service
public class OpenAiService {

    private final ChatClient chatClient;
    private final ImageModel imageModel;
    private final OpenAiAudioTranscriptionModel transcriptionModel;
    private final OpenAiAudioSpeechModel speechModel;
    private final EmbeddingModel embeddingModel;

    @Value("${spring.ai.openai.chat.options.model:gpt-4o}")
    private String chatModelName;

    @Value("${spring.ai.openai.embedding.options.model:text-embedding-3-small}")
    private String embeddingModelName;

    @Value("${spring.ai.openai.image.options.model:dall-e-3}")
    private String imageModelName;

    public OpenAiService(
            @Qualifier("client") ChatClient chatClient,
            @Autowired(required = false) ImageModel imageModel,
            @Autowired(required = false) OpenAiAudioTranscriptionModel transcriptionModel,
            @Autowired(required = false) OpenAiAudioSpeechModel speechModel,
            @Autowired(required = false) EmbeddingModel embeddingModel
    ) {
        this.chatClient = chatClient;
        this.imageModel = imageModel;
        this.transcriptionModel = transcriptionModel;
        this.speechModel = speechModel;
        this.embeddingModel = embeddingModel;
    }

    public String describeImage(String prompt, byte[] imageBytes, String mimeType) {
        MimeType resolvedMimeType = MimeTypeUtils.IMAGE_JPEG;
        if (mimeType != null && mimeType.contains("png")) {
            resolvedMimeType = MimeTypeUtils.IMAGE_PNG;
        } else if (mimeType != null && mimeType.contains("webp")) {
            resolvedMimeType = MimeType.valueOf("image/webp");
        } else if (mimeType != null && mimeType.contains("gif")) {
            resolvedMimeType = MimeTypeUtils.IMAGE_GIF;
        }

        final MimeType mediaType = resolvedMimeType;
        String promptText = (prompt != null && !prompt.isBlank()) ? prompt : "Describe this image in detail.";
        return chatClient.prompt()
                .user(u -> u.text(promptText)
                        .media(mediaType, new ByteArrayResource(imageBytes)))
                .call()
                .content();
    }

    public String generateImage(String prompt) {
        if (imageModel == null) {
            throw new IllegalStateException("OpenAI ImageModel is not configured");
        }
        ImageResponse response = imageModel.call(new ImagePrompt(prompt));
        return response.getResult().getOutput().getUrl();
    }

    public String transcribe(byte[] audioBytes, String filename) {
        if (transcriptionModel == null) {
            throw new IllegalStateException("OpenAI AudioTranscriptionModel is not configured");
        }
        ByteArrayResource resource = new ByteArrayResource(audioBytes) {
            @Override
            public String getFilename() {
                return (filename != null && !filename.isBlank()) ? filename : "audio.wav";
            }
        };
        return transcriptionModel.call(new AudioTranscriptionPrompt(resource)).getResult().getOutput();
    }

    public byte[] textToSpeech(String text) {
        if (speechModel == null) {
            throw new IllegalStateException("OpenAI AudioSpeechModel is not configured");
        }
        return speechModel.call(text);
    }

    public float[] embed(String text) {
        if (embeddingModel == null) {
            throw new IllegalStateException("OpenAI EmbeddingModel is not configured");
        }
        return embeddingModel.embed(text);
    }

    public List<float[]> embedList(List<String> texts) {
        if (embeddingModel == null) {
            throw new IllegalStateException("OpenAI EmbeddingModel is not configured");
        }
        return embeddingModel.embedForResponse(texts).getResults().stream()
                .map(r -> r.getOutput())
                .toList();
    }
}
