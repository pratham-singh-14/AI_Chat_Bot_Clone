package com.pratham.chatbot;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pratham.chatbot.ai_services.embedding.ImageGeneration;
import com.pratham.chatbot.ai_services.embedding.Transcription;
import com.pratham.chatbot.controller.CommonController;
import com.pratham.chatbot.controller.PdfController;
import com.pratham.chatbot.dto.*;
import com.pratham.chatbot.entity.Conversation;
import com.pratham.chatbot.entity.Message;
import com.pratham.chatbot.exception.GlobalExceptionHandler;
import com.pratham.chatbot.repository.ConversationRepo;
import com.pratham.chatbot.repository.MessageRepository;
import com.pratham.chatbot.service.ConversationService;
import com.pratham.chatbot.service.MessageService;
import com.pratham.chatbot.service.OpenAiService;
import com.pratham.chatbot.service.rag.PdfRagService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
public class EndpointContractTest {

    private MockMvc mockMvc;
    private ObjectMapper objectMapper = new ObjectMapper();

    @Mock
    private OpenAiService openAiService;

    @Mock
    private ConversationRepo conversationRepo;

    @Mock
    private MessageRepository messageRepository;

    @Mock
    private PdfRagService pdfRagService;

    @Mock
    private ChatClient chatClient;

    private ConversationService conversationService;
    private MessageService messageService;

    @BeforeEach
    void setUp() {
        conversationService = new ConversationService(conversationRepo, messageRepository);
        messageService = new MessageService(messageRepository, conversationRepo, chatClient, chatClient, openAiService);

        CommonController commonController = new CommonController(chatClient, conversationService, messageService);
        PdfController pdfController = new PdfController(pdfRagService);
        ImageGeneration imageGeneration = new ImageGeneration(openAiService, messageService);
        Transcription transcription = new Transcription(openAiService, messageService);

        mockMvc = MockMvcBuilders
                .standaloneSetup(commonController, pdfController, imageGeneration, transcription)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void testSessionEndpointContract() throws Exception {
        mockMvc.perform(get("/session"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.clientId").isString());
    }

    @Test
    void testCreateConversationContract() throws Exception {
        CoversationRequestDto request = new CoversationRequestDto();
        request.setClientId("test-client-123");

        mockMvc.perform(post("/conversations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.conversationId").isString());
    }

    @Test
    void testCreateConversationMissingClientIdReturns400() throws Exception {
        CoversationRequestDto request = new CoversationRequestDto();

        mockMvc.perform(post("/conversations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.msg").value("ClientId not found"));
    }

    @Test
    void testFetchConversationsContract() throws Exception {
        Conversation c = Conversation.builder()
                .conversationId("conv-1")
                .clientId("client-1")
                .title("My Title")
                .build();
        when(conversationRepo.findByClientId("client-1")).thenReturn(List.of(c));

        mockMvc.perform(get("/conversations/client-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].conversationId").value("conv-1"))
                .andExpect(jsonPath("$[0].title").value("My Title"));
    }

    @Test
    void testDeleteConversationContract() throws Exception {
        when(conversationRepo.existsById("conv-1")).thenReturn(true);

        mockMvc.perform(delete("/conversations/conv-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.msg").value("Conversation deleted successfully"));
    }

    @Test
    void testDeleteConversationNotFound() throws Exception {
        when(conversationRepo.existsById("non-existent")).thenReturn(false);

        mockMvc.perform(delete("/conversations/non-existent"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.msg").value("Conversation not found"));
    }

    @Test
    void testFetchMessagesContract() throws Exception {
        Message msg = Message.builder()
                .id(1L)
                .conversationId("conv-1")
                .role("USER")
                .message("Hello")
                .type("text")
                .build();
        when(messageRepository.findByConversationId("conv-1")).thenReturn(List.of(msg));

        mockMvc.perform(get("/messages/conv-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].role").value("USER"))
                .andExpect(jsonPath("$[0].message").value("Hello"));
    }

    @Test
    void testSendMessageMissingConversationIdReturns400() throws Exception {
        MessageRequest req = new MessageRequest();
        req.setMessage("Hello");

        mockMvc.perform(post("/messages")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.msg").value("ConversationId not found in this request"));
    }

    @Test
    void testGenImageContract() throws Exception {
        when(openAiService.generateImage("sunset")).thenReturn("https://image.url/sunset.png");

        mockMvc.perform(post("/gen-image")
                        .param("msg", "sunset")
                        .param("conversationId", "conv-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.response").value("https://image.url/sunset.png"))
                .andExpect(jsonPath("$.conversationId").value("conv-1"));
    }

    @Test
    void testDescribeEditImageContract() throws Exception {
        when(openAiService.describeImage(anyString(), any(), anyString()))
                .thenReturn("A beautiful cat in the garden");

        MockMultipartFile file = new MockMultipartFile(
                "file", "cat.jpg", "image/jpeg", "fake-image-bytes".getBytes()
        );

        mockMvc.perform(multipart("/describe-edit-image")
                        .file(file)
                        .param("msg", "What is this?")
                        .param("conversationId", "conv-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.response").value("A beautiful cat in the garden"))
                .andExpect(jsonPath("$.conversationId").value("conv-1"));
    }

    @Test
    void testSpeechToTextContract() throws Exception {
        when(openAiService.transcribe(any(), anyString())).thenReturn("Transcribed voice text");

        MockMultipartFile file = new MockMultipartFile(
                "file", "voice.wav", "audio/wav", "fake-audio-bytes".getBytes()
        );

        mockMvc.perform(multipart("/speech-to-text")
                        .file(file)
                        .param("conversationId", "conv-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.response").value("Transcribed voice text"))
                .andExpect(jsonPath("$.conversationId").value("conv-1"));
    }

    @Test
    void testTextToSpeechContract() throws Exception {
        when(openAiService.textToSpeech("Hello world")).thenReturn("fake-audio-wav".getBytes());

        mockMvc.perform(post("/text-to-speech")
                        .param("text", "Hello world")
                        .param("conversationId", "conv-1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("audio/wav"))
                .andExpect(content().bytes("fake-audio-wav".getBytes()));
    }

    @Test
    void testPdfListContract() throws Exception {
        PdfInfoResponse info = PdfInfoResponse.builder()
                .id("pdf-1")
                .name("sample.pdf")
                .pages(5)
                .size(1024)
                .uploadTime("2026-11-05 12:00:00")
                .build();
        when(pdfRagService.listAllPdfs()).thenReturn(List.of(info));

        mockMvc.perform(get("/pdf/list"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value("pdf-1"))
                .andExpect(jsonPath("$[0].name").value("sample.pdf"))
                .andExpect(jsonPath("$[0].pages").value(5));
    }

    @Test
    void testPdfUploadContract() throws Exception {
        PdfInfoResponse info = PdfInfoResponse.builder()
                .id("pdf-new")
                .name("test.pdf")
                .pages(2)
                .size(2048)
                .uploadTime("2026-11-05 12:00:00")
                .build();
        when(pdfRagService.uploadAndIndexPdf(any())).thenReturn(info);

        MockMultipartFile file = new MockMultipartFile(
                "file", "test.pdf", "application/pdf", "fake-pdf".getBytes()
        );

        mockMvc.perform(multipart("/pdf/upload").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value("pdf-new"))
                .andExpect(jsonPath("$.name").value("test.pdf"))
                .andExpect(jsonPath("$.pages").value(2));
    }

    @Test
    void testPdfAskContract() throws Exception {
        SourceCitation citation = SourceCitation.builder()
                .pdfId("pdf-1")
                .pdfName("sample.pdf")
                .page(1)
                .snippet("Sample excerpt")
                .score(0.89)
                .build();

        PdfChatResponse response = PdfChatResponse.builder()
                .response("The document says excerpt.")
                .conversationId("conv-1")
                .sources(List.of(citation))
                .build();

        when(pdfRagService.askQuestion(any())).thenReturn(response);

        PdfChatRequest req = PdfChatRequest.builder()
                .pdfIds(List.of("pdf-1"))
                .question("What does it say?")
                .conversationId("conv-1")
                .build();

        mockMvc.perform(post("/pdf/ask")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.response").value("The document says excerpt."))
                .andExpect(jsonPath("$.sources[0].pdfName").value("sample.pdf"))
                .andExpect(jsonPath("$.sources[0].page").value(1));
    }

    @Test
    void testPdfDeleteContract() throws Exception {
        when(pdfRagService.deletePdf("pdf-1")).thenReturn(true);

        mockMvc.perform(delete("/pdf/pdf-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.msg").value("PDF deleted successfully"));
    }
}
