package com.pratham.chatbot.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleException(Exception ex) {

        Throwable cause = ex;
        String combinedMessage = "";
        while (cause != null) {
            if (cause.getMessage() != null) {
                combinedMessage = combinedMessage + " " + cause.getMessage();
            }
            cause = cause.getCause();
        }
        String lower = combinedMessage.toLowerCase();

        boolean isQuotaError = lower.contains("429")
                || lower.contains("quota")
                || lower.contains("resource_exhausted")
                || lower.contains("rate limit")
                || lower.contains("rate_limit")
                || lower.contains("insufficient_quota")
                || lower.contains("too many requests");

        boolean isAuthError = lower.contains("401")
                || lower.contains("invalid api key")
                || lower.contains("incorrect api key")
                || lower.contains("invalid_api_key")
                || lower.contains("unauthorized");

        Map<String, Object> body = new HashMap<>();

        if (isAuthError) {
            body.put("error", "UNAUTHORIZED");
            body.put("message", "Invalid or missing OpenAI API Key. Please check your .env configuration.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(body);
        }

        if (isQuotaError) {
            body.put("error", "QUOTA_EXCEEDED");
            body.put("message", "Token/rate limit exceeded, please try again after some time.");
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body(body);
        }

        if (ex instanceof MaxUploadSizeExceededException
                || ex instanceof MissingServletRequestPartException
                || ex instanceof IllegalArgumentException) {
            body.put("error", "BAD_REQUEST");
            body.put("message", ex.getMessage() != null ? ex.getMessage() : "Invalid Request Format!!");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
        }

        body.put("error", "INTERNAL_ERROR");
        body.put("message", ex.getMessage() != null ? ex.getMessage() : "Something went wrong on the server side");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
