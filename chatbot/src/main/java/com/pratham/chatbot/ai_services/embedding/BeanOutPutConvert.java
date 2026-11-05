package com.pratham.chatbot.ai_services.embedding;

import com.pratham.chatbot.entity.MovieModel;
import com.pratham.chatbot.entity.MovieResponse;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.ai.converter.ListOutputConverter;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.convert.support.DefaultConversionService;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@CrossOrigin("*")
public class BeanOutPutConvert {


    private final ChatClient chatClient;


    public BeanOutPutConvert(@Qualifier("client") ChatClient chatClient) {
        this.chatClient = chatClient;
    }


    @GetMapping("/movies")
    public MovieResponse getMovies(@RequestParam String actorName){

        BeanOutputConverter<MovieResponse> outputConverter = new BeanOutputConverter<>(MovieResponse.class);

        MovieResponse  movies = chatClient.prompt().user(u -> u.text("List of minimum 5 movies of {actorName}").param("actorName",actorName))
                .call().entity(new BeanOutputConverter<MovieResponse>(MovieResponse.class));

        return movies;

    }
}
