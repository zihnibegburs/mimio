package com.mimio.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mimio.ollama")
public record OllamaProperties(
        String baseUrl,
        String model,
        int timeoutSeconds
) {
    public OllamaProperties {
        if (baseUrl == null) baseUrl = "http://localhost:11434";
        if (model == null) model = "llama3.2:3b";
        if (timeoutSeconds <= 0) timeoutSeconds = 120;
    }
}
