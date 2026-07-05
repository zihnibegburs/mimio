ALTER TABLE tasks ADD COLUMN energy_level VARCHAR(10);
ALTER TABLE tasks ADD COLUMN motivation VARCHAR(500);
ALTER TABLE tasks ADD COLUMN transition_buffer_minutes INT NOT NULL DEFAULT 0;
