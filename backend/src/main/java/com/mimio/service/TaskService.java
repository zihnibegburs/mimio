package com.mimio.service;

import com.mimio.domain.entity.Task;
import com.mimio.domain.entity.User;
import com.mimio.domain.enums.TaskStatus;
import com.mimio.domain.repository.TaskRepository;
import com.mimio.dto.task.*;
import com.mimio.exception.BadRequestException;
import com.mimio.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final FocusSessionService focusSessionService;

    public TimelineResponse getTimeline(User user, LocalDate date) {
        Instant dayStart = date.atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant dayEnd = date.plusDays(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        List<Task> allTasks = taskRepository.findTimelineTasks(user, dayStart, dayEnd);

        List<UUID> parentIds = allTasks.stream()
                .filter(t -> t.getParentTask() == null)
                .map(Task::getId)
                .toList();

        Map<UUID, List<Task>> subtasksByParent = parentIds.isEmpty()
                ? Map.of()
                : taskRepository.findByUserAndParentTaskIdInOrderBySortOrderAsc(user, parentIds)
                        .stream()
                        .collect(Collectors.groupingBy(t -> t.getParentTask().getId()));

        List<TaskResponse> tasks = allTasks.stream()
                .filter(t -> t.getParentTask() == null)
                .map(t -> TaskResponse.from(t, subtasksByParent.getOrDefault(t.getId(), List.of())))
                .toList();

        TaskResponse activeTask = taskRepository
                .findByUserAndStatus(user, TaskStatus.IN_PROGRESS)
                .or(() -> taskRepository.findByUserAndStatus(user, TaskStatus.PAUSED))
                .map(TaskResponse::from)
                .orElse(null);

        return new TimelineResponse(date, tasks, activeTask);
    }

    public List<TaskResponse> getInbox(User user) {
        return taskRepository.findByUserAndIsInboxTrueOrderByCreatedAtDesc(user)
                .stream()
                .map(TaskResponse::from)
                .toList();
    }

    @Transactional
    public TaskResponse createTask(User user, CreateTaskRequest request) {
        Task task = Task.builder()
                .user(user)
                .title(request.title().trim())
                .description(request.description())
                .color(request.color() != null ? request.color() : "#6C63FF")
                .icon(request.icon() != null ? request.icon() : "task")
                .durationMinutes(request.durationMinutes() != null ? request.durationMinutes() : 30)
                .scheduledAt(request.scheduledAt())
                .isInbox(request.isInbox() != null ? request.isInbox() : false)
                .sortOrder(request.sortOrder() != null ? request.sortOrder() : 0)
                .build();

        if (request.parentTaskId() != null) {
            Task parent = findTaskOrThrow(user, request.parentTaskId());
            task.setParentTask(parent);
        }

        return TaskResponse.from(taskRepository.save(task));
    }

    @Transactional
    public TaskResponse createTaskWithSubtasks(User user, CreateTaskWithSubtasksRequest request) {
        int totalDuration = request.subtasks().stream()
                .mapToInt(SubtaskRequest::durationMinutes)
                .sum();

        String color = request.color() != null ? request.color() : "#6C63FF";
        String icon = request.icon() != null ? request.icon() : "task";

        Task parent = Task.builder()
                .user(user)
                .title(request.title().trim())
                .description(request.description())
                .color(color)
                .icon(icon)
                .durationMinutes(totalDuration)
                .scheduledAt(request.scheduledAt())
                .isInbox(false)
                .sortOrder(0)
                .build();
        parent = taskRepository.save(parent);

        Instant current = request.scheduledAt();
        List<Task> subtasks = new ArrayList<>();
        int order = 0;
        for (SubtaskRequest sub : request.subtasks()) {
            Task child = Task.builder()
                    .user(user)
                    .title(sub.title().trim())
                    .color(sub.color() != null ? sub.color() : color)
                    .icon(icon)
                    .durationMinutes(sub.durationMinutes())
                    .scheduledAt(current)
                    .parentTask(parent)
                    .sortOrder(order++)
                    .build();
            subtasks.add(taskRepository.save(child));
            if (current != null) {
                current = current.plus(sub.durationMinutes(), ChronoUnit.MINUTES);
            }
        }

        return TaskResponse.from(parent, subtasks);
    }

    @Transactional
    public TaskResponse updateTask(User user, UUID taskId, UpdateTaskRequest request) {
        Task task = findTaskOrThrow(user, taskId);
        applyUpdates(task, request);
        return TaskResponse.from(taskRepository.save(task));
    }

    @Transactional
    public void deleteTask(User user, UUID taskId) {
        Task task = findTaskOrThrow(user, taskId);
        if (task.getStatus() == TaskStatus.IN_PROGRESS || task.getStatus() == TaskStatus.PAUSED) {
            focusSessionService.clearSession(user.getId());
        }
        taskRepository.delete(task);
    }

    @Transactional
    public TaskResponse startTask(User user, UUID taskId) {
        pauseActiveTaskIfAny(user);

        Task task = findTaskOrThrow(user, taskId);
        if (task.getStatus() == TaskStatus.COMPLETED) {
            throw new BadRequestException("Cannot start a completed task");
        }

        if (task.getStatus() == TaskStatus.PAUSED) {
            task.setStatus(TaskStatus.IN_PROGRESS);
            focusSessionService.resumeSession(task);
        } else {
            task.setStatus(TaskStatus.IN_PROGRESS);
            task.setStartedAt(Instant.now());
            focusSessionService.startSession(task);
        }

        return TaskResponse.from(taskRepository.save(task));
    }

    @Transactional
    public TaskResponse pauseTask(User user, UUID taskId) {
        Task task = findTaskOrThrow(user, taskId);
        if (task.getStatus() != TaskStatus.IN_PROGRESS) {
            throw new BadRequestException("Task is not in progress");
        }

        task.setStatus(TaskStatus.PAUSED);
        focusSessionService.pauseSession(user.getId());
        return TaskResponse.from(taskRepository.save(task));
    }

    @Transactional
    public TaskResponse completeTask(User user, UUID taskId) {
        Task task = findTaskOrThrow(user, taskId);
        task.setStatus(TaskStatus.COMPLETED);
        task.setCompletedAt(Instant.now());
        focusSessionService.clearSession(user.getId());
        taskRepository.save(task);

        if (task.getParentTask() != null) {
            Task parent = task.getParentTask();
            List<Task> siblings = taskRepository.findByUserAndParentTaskIdOrderBySortOrderAsc(user, parent.getId());
            boolean allDone = siblings.stream().allMatch(t -> t.getStatus() == TaskStatus.COMPLETED);
            if (allDone && parent.getStatus() != TaskStatus.COMPLETED) {
                parent.setStatus(TaskStatus.COMPLETED);
                parent.setCompletedAt(Instant.now());
                taskRepository.save(parent);
            }
        }

        return TaskResponse.from(task);
    }

    @Transactional
    public TaskResponse scheduleFromInbox(User user, UUID taskId, Instant scheduledAt) {
        Task task = findTaskOrThrow(user, taskId);
        if (!task.getIsInbox()) {
            throw new BadRequestException("Task is not in inbox");
        }

        task.setIsInbox(false);
        task.setScheduledAt(scheduledAt);
        return TaskResponse.from(taskRepository.save(task));
    }

    private void pauseActiveTaskIfAny(User user) {
        taskRepository.findByUserAndStatus(user, TaskStatus.IN_PROGRESS)
                .ifPresent(active -> {
                    active.setStatus(TaskStatus.PAUSED);
                    taskRepository.save(active);
                    focusSessionService.pauseSession(user.getId());
                });
    }

    private Task findTaskOrThrow(User user, UUID taskId) {
        return taskRepository.findByIdAndUser(taskId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
    }

    private void applyUpdates(Task task, UpdateTaskRequest request) {
        if (request.title() != null) task.setTitle(request.title().trim());
        if (request.description() != null) task.setDescription(request.description());
        if (request.color() != null) task.setColor(request.color());
        if (request.icon() != null) task.setIcon(request.icon());
        if (request.durationMinutes() != null) task.setDurationMinutes(request.durationMinutes());
        if (request.scheduledAt() != null) task.setScheduledAt(request.scheduledAt());
        if (request.status() != null) task.setStatus(request.status());
        if (request.sortOrder() != null) task.setSortOrder(request.sortOrder());
        if (request.isInbox() != null) task.setIsInbox(request.isInbox());
    }
}
