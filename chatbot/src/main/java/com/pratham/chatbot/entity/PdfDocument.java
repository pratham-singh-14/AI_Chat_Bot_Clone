package com.pratham.chatbot.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "pdf_documents")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PdfDocument {

    @Id
    private String id;

    private String name;

    private int pages;

    private long size;

    private String uploadTime;

    private String filePath;
}
