ALTER TABLE tasks
    ADD COLUMN recurrence_type VARCHAR(20) NOT NULL DEFAULT 'NONE',
    ADD COLUMN recurrence_interval INT NOT NULL DEFAULT 1,
    ADD COLUMN recurrence_unit VARCHAR(10),
    ADD COLUMN recurrence_series_id UUID;

CREATE INDEX idx_tasks_recurrence_series ON tasks(recurrence_series_id)
    WHERE recurrence_series_id IS NOT NULL;
