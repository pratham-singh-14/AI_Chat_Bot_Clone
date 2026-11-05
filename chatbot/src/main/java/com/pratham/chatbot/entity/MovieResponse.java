package com.pratham.chatbot.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MovieResponse {

    private boolean success;
    private String msg;
    private List<MovieModel> data;


}
