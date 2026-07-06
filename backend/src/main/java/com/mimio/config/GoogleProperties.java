package com.mimio.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mimio.google")
public record GoogleProperties(String clientId) {}
