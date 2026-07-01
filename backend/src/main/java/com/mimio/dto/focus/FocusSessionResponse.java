package com.mimio.dto.focus;

import com.mimio.domain.enums.TaskStatus;

import java.time.Instant;
import java.util.UUID;

public record FocusSessionResponse(
        UUID taskId,
        String title,
        String color,
        int durationMinutes,
        TaskStatus status,
        Instant startedAt,
        long elapsedSeconds,
        long remainingSeconds,
        double progressPercent
) {}
