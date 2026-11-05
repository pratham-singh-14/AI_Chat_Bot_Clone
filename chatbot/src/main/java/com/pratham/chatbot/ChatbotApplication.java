package com.pratham.chatbot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@SpringBootApplication
public class ChatbotApplication {

	public static void main(String[] args) {
		loadEnv();
		SpringApplication.run(ChatbotApplication.class, args);
	}

	private static void loadEnv() {
		try {
			Path envPath = Path.of(".env");
			if (!Files.exists(envPath)) {
				envPath = Path.of("..", ".env");
			}
			if (Files.exists(envPath)) {
				List<String> lines = Files.readAllLines(envPath);
				for (String line : lines) {
					line = line.trim();
					if (line.isEmpty() || line.startsWith("#")) continue;
					int idx = line.indexOf('=');
					if (idx > 0) {
						String key = line.substring(0, idx).trim();
						String val = line.substring(idx + 1).trim();
						if ((val.startsWith("\"") && val.endsWith("\"")) ||
							(val.startsWith("'") && val.endsWith("'"))) {
							val = val.substring(1, val.length() - 1);
						}
						if (System.getProperty(key) == null && System.getenv(key) == null) {
							System.setProperty(key, val);
						}
					}
				}
			}
		} catch (Exception ignored) {
		}
	}

}
