package com.mimio.controller;

import com.mimio.domain.entity.Task;
import com.mimio.domain.enums.TaskStatus;
import com.mimio.domain.repository.TaskRepository;
import com.mimio.dto.focus.FocusSessionResponse;
import com.mimio.security.CurrentUserService;
import com.mimio.service.FocusSessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/focus")
@RequiredArgsConstructor
public class FocusController {

    private final FocusSessionService focusSessionService;
    private final TaskRepository taskRepository;
    private final CurrentUserService currentUserService;

    @GetMapping("/session")
    public ResponseEntity<FocusSessionResponse> getActiveSession() {
        var user = currentUserService.getCurrentUser();
        Task task = taskRepository.findByUserAndStatus(user, TaskStatus.IN_PROGRESS)
                .or(() -> taskRepository.findByUserAndStatus(user, TaskStatus.PAUSED))
                .orElse(null);

        if (task == null) {
            return ResponseEntity.noContent().build();
        }

        return focusSessionService.getActiveSession(user.getId(), task)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.noContent().build());
    }
}
