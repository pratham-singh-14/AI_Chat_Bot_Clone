package com.pratham.chatbot.ai_services.embedding;

import org.springframework.ai.chat.client.ChatClient;
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
public class ListOutPutConvert {



    private final ChatClient chatClient;

    public ListOutPutConvert(@Qualifier("client") ChatClient chatClient) {
        this.chatClient = chatClient;
    }


    @GetMapping("/movie-list")
    public List<String> getMovies(@RequestParam String actorName){


        List<String>  movies = chatClient.prompt().user(u -> u.text("List of minimum 5 movies of {actorName}").param("actorName",actorName))
                .call().entity(new ListOutputConverter(new DefaultConversionService()));

        return movies;

    }
    
}
