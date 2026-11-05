package com.pratham.chatbot.controller;

import com.pratham.chatbot.dto.PdfChatRequest;
import com.pratham.chatbot.dto.PdfChatResponse;
import com.pratham.chatbot.dto.PdfInfoResponse;
import com.pratham.chatbot.service.rag.PdfRagService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin("*")
@RequestMapping("/pdf")
public class PdfController {

    private final PdfRagService pdfRagService;

    public PdfController(PdfRagService pdfRagService) {
        this.pdfRagService = pdfRagService;
    }

    @PostMapping("/upload")
    public ResponseEntity<PdfInfoResponse> uploadPdf(@RequestParam("file") MultipartFile file) throws IOException {
        PdfInfoResponse response = pdfRagService.uploadAndIndexPdf(file);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/list")
    public ResponseEntity<List<PdfInfoResponse>> listPdfs() {
        return ResponseEntity.ok(pdfRagService.listAllPdfs());
    }

    @DeleteMapping("/{pdfId}")
    public ResponseEntity<?> deletePdf(@PathVariable String pdfId) {
        boolean deleted = pdfRagService.deletePdf(pdfId);
        if (!deleted) {
            return ResponseEntity.status(404).body(Map.of("msg", "PDF document not found"));
        }
        return ResponseEntity.ok(Map.of("msg", "PDF deleted successfully"));
    }

    @PostMapping("/ask")
    public ResponseEntity<PdfChatResponse> askPdf(@RequestBody PdfChatRequest request) {
        PdfChatResponse response = pdfRagService.askQuestion(request);
        return ResponseEntity.ok(response);
    }
}
