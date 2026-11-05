package com.pratham.chatbot.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MovieModel {

    private String movieName;
    private String BasicPloting;
    private String releaseYear;
    private String cast;
    private String length;
    private String imdbRatuing;

}
