package com.pratham.chatbot.ai_services.embedding;


import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@CrossOrigin("*")
public class Embedding {

    private final EmbeddingModel embeddingModel;


    public Embedding(EmbeddingModel embeddingModel) {
        this.embeddingModel = embeddingModel;
    }

    @GetMapping("/embed/{msg}")
    public float[] generateEmbed(@PathVariable String msg)
    {

        return embeddingModel.embed(msg);

    }



    @GetMapping("/similarity")
    public double similarity(@RequestParam String text1,@RequestParam String text2)
    {

        EmbeddingResponse response = embeddingModel.embedForResponse(List.of(text1,text2));




       float[] text_embed1=  response.getResults().get(0).getOutput();
       float[] text_embed2= response.getResults().get(1).getOutput();

       double dotProduct = 0.0;
       double normA = 0.0;
       double normB = 0.0;

       for (int i =0; i <  text_embed1.length;i++)
       {

           dotProduct += text_embed1[i] * text_embed2[i];
           normA += Math.pow(text_embed1[i],2);
           normB += Math.pow(text_embed2[i],2);

       }

       if(normA == 0.0 || normB == 0.0){
           return  0.0;
       }
      return dotProduct/Math.sqrt(normA) * Math.sqrt(normB);


    }


}
