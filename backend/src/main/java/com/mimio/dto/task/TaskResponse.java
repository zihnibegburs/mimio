package com.mimio.dto.task;

import com.mimio.domain.entity.Task;
import com.mimio.domain.enums.TaskStatus;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record TaskResponse(
        UUID id,
        String title,
        String description,
        String color,
        String icon,
        Integer durationMinutes,
        Instant scheduledAt,
        TaskStatus status,
        Integer sortOrder,
        Boolean isInbox,
        Instant startedAt,
        Instant completedAt,
        Instant createdAt,
        UUID parentTaskId,
        List<TaskResponse> subtasks
) {
    public static TaskResponse from(Task task) {
        return from(task, List.of());
    }

    public static TaskResponse from(Task task, List<Task> subtasks) {
        return new TaskResponse(
                task.getId(),
                task.getTitle(),
                task.getDescription(),
                task.getColor(),
                task.getIcon(),
                task.getDurationMinutes(),
                task.getScheduledAt(),
                task.getStatus(),
                task.getSortOrder(),
                task.getIsInbox(),
                task.getStartedAt(),
                task.getCompletedAt(),
                task.getCreatedAt(),
                task.getParentTask() != null ? task.getParentTask().getId() : null,
                subtasks.stream().map(TaskResponse::from).toList()
        );
    }
}
