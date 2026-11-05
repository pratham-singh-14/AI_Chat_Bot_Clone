package com.pratham.chatbot.ai_services.embedding;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.ListOutputConverter;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin("*")
public class PromptTemplates {


    private final ChatClient chatClient;

    public PromptTemplates(@Qualifier("client") ChatClient chatClient) {
        this.chatClient = chatClient;
    }


    @GetMapping("/recommend")
    public String  getMovies(@RequestParam String type, @RequestParam String year, @RequestParam String lang){


        String text = """
                                I want to watch a {type} movie tonight with good rating,\s
                                looking  for movies around this year {year}.\s
                                The  language im looking for is {lang}.
                                Suggest one specific movie and tell me the cast and length of the movie.
                     
                
                                response format should be:
                                1. Movie Name
                                2. basic plot
                                3. cast
                                4. length
                                5. IMDB rating
                
                """;

        PromptTemplate template = new PromptTemplate(text);

        Prompt prompt = template.create(Map.of("type",type,"year",year,"lang",lang));



        return chatClient.prompt(prompt).call().content();

    }


}
