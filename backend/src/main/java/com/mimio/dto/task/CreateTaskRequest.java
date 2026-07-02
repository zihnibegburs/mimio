package com.mimio.dto.task;

import com.mimio.domain.enums.RecurrenceType;
import com.mimio.domain.enums.RecurrenceUnit;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.UUID;

public record CreateTaskRequest(
        @NotBlank @Size(max = 255) String title,
        String description,
        String color,
        String icon,
        @Positive Integer durationMinutes,
        Instant scheduledAt,
        Boolean isInbox,
        Integer sortOrder,
        UUID parentTaskId,
        RecurrenceType recurrenceType,
        Integer recurrenceInterval,
        RecurrenceUnit recurrenceUnit,
        @Size(max = 500) String reward
) {}
