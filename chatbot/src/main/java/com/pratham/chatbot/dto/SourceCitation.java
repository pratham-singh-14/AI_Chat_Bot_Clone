package com.pratham.chatbot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SourceCitation {
    private String pdfId;
    private String pdfName;
    private int page;
    private String snippet;
    private double score;
}
