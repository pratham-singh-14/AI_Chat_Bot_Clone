package com.pratham.chatbot.service.rag;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PdfVectorChunk {
    private String pdfId;
    private String pdfName;
    private int page;
    private int chunkIndex;
    private String text;
    private float[] embedding;
}
