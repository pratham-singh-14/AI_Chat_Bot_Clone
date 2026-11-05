package com.pratham.chatbot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PdfInfoResponse {
    private String id;
    private String name;
    private int pages;
    private long size;
    private String uploadTime;
}
