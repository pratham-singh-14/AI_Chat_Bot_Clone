package com.pratham.chatbot.repository;

import com.pratham.chatbot.entity.PdfDocument;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PdfDocumentRepository extends JpaRepository<PdfDocument, String> {
}
