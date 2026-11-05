package com.pratham.chatbot;

import com.pratham.chatbot.dto.PdfChatRequest;
import com.pratham.chatbot.dto.PdfChatResponse;
import com.pratham.chatbot.dto.PdfInfoResponse;
import com.pratham.chatbot.entity.PdfDocument;
import com.pratham.chatbot.repository.PdfDocumentRepository;
import com.pratham.chatbot.service.MessageService;
import com.pratham.chatbot.service.OpenAiService;
import com.pratham.chatbot.service.rag.PdfRagService;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Answers;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.mock.web.MockMultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class PdfRagServiceTest {

    @Mock
    private PdfDocumentRepository pdfDocumentRepository;

    @Mock
    private OpenAiService openAiService;

    @Mock
    private MessageService messageService;

    @Mock(answer = Answers.RETURNS_DEEP_STUBS)
    private ChatClient chatClient;

    private PdfRagService pdfRagService;

    @BeforeEach
    void setUp() {
        pdfRagService = new PdfRagService(pdfDocumentRepository, openAiService, messageService, chatClient);
    }

    private byte[] createSamplePdf(String content) throws IOException {
        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage();
            document.addPage(page);
            try (PDPageContentStream stream = new PDPageContentStream(document, page)) {
                stream.beginText();
                stream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                stream.newLineAtOffset(50, 700);
                stream.showText(content);
                stream.endText();
            }
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            document.save(baos);
            return baos.toByteArray();
        }
    }

    @Test
    void testUploadAndIndexPdf() throws IOException {
        byte[] pdfBytes = createSamplePdf("Flutter GetX reactive state management is awesome.");
        MockMultipartFile file = new MockMultipartFile("file", "flutter_guide.pdf", "application/pdf", pdfBytes);

        when(openAiService.embedList(anyList())).thenReturn(List.of(new float[]{0.1f, 0.2f, 0.3f}));

        PdfInfoResponse response = pdfRagService.uploadAndIndexPdf(file);

        assertNotNull(response);
        assertNotNull(response.getId());
        assertEquals("flutter_guide.pdf", response.getName());
        assertEquals(1, response.getPages());
        verify(pdfDocumentRepository, times(1)).save(any(PdfDocument.class));
    }

    @Test
    void testUploadEmptyPdfThrowsException() {
        MockMultipartFile file = new MockMultipartFile("file", "empty.pdf", "application/pdf", new byte[0]);
        assertThrows(IllegalArgumentException.class, () -> pdfRagService.uploadAndIndexPdf(file));
    }

    @Test
    void testUploadNonPdfThrowsException() {
        MockMultipartFile file = new MockMultipartFile("file", "data.txt", "text/plain", "hello".getBytes());
        assertThrows(IllegalArgumentException.class, () -> pdfRagService.uploadAndIndexPdf(file));
    }

    @Test
    void testAskQuestionStrictIsolation() throws IOException {
        // Upload Document A
        byte[] pdfA = createSamplePdf("Document Alpha contains secret code ALPHA999.");
        MockMultipartFile fileA = new MockMultipartFile("file", "docA.pdf", "application/pdf", pdfA);
        when(openAiService.embedList(anyList())).thenReturn(List.of(new float[]{1.0f, 0.0f, 0.0f}));
        PdfInfoResponse resA = pdfRagService.uploadAndIndexPdf(fileA);

        // Upload Document B
        byte[] pdfB = createSamplePdf("Document Beta contains confidential pin BETA777.");
        MockMultipartFile fileB = new MockMultipartFile("file", "docB.pdf", "application/pdf", pdfB);
        when(openAiService.embedList(anyList())).thenReturn(List.of(new float[]{0.0f, 1.0f, 0.0f}));
        PdfInfoResponse resB = pdfRagService.uploadAndIndexPdf(fileB);

        // Query ONLY Document A
        when(openAiService.embed(anyString())).thenReturn(new float[]{1.0f, 0.0f, 0.0f});
        when(chatClient.prompt(anyString()).call().content()).thenReturn("The secret code is ALPHA999 [docA.pdf p.1]");

        PdfChatRequest req = PdfChatRequest.builder()
                .pdfIds(List.of(resA.getId())) // Only Doc A selected!
                .question("What is the secret code?")
                .build();

        PdfChatResponse chatResponse = pdfRagService.askQuestion(req);

        assertNotNull(chatResponse);
        assertEquals("The secret code is ALPHA999 [docA.pdf p.1]", chatResponse.getResponse());
        // Verify sources strictly contain only Document A
        assertFalse(chatResponse.getSources().isEmpty());
        for (var source : chatResponse.getSources()) {
            assertEquals(resA.getId(), source.getPdfId());
            assertEquals("docA.pdf", source.getPdfName());
            assertNotEquals("docB.pdf", source.getPdfName());
        }

        // Clean up
        pdfRagService.deletePdf(resA.getId());
        pdfRagService.deletePdf(resB.getId());
    }

    @Test
    void testAskQuestionMissingPdfIdsThrowsException() {
        PdfChatRequest req = PdfChatRequest.builder()
                .pdfIds(List.of())
                .question("Hello?")
                .build();
        assertThrows(IllegalArgumentException.class, () -> pdfRagService.askQuestion(req));
    }
}
