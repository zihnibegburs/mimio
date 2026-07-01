CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    avatar_color VARCHAR(7) NOT NULL DEFAULT '#6C63FF',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    color           VARCHAR(7) NOT NULL DEFAULT '#6C63FF',
    icon            VARCHAR(50) NOT NULL DEFAULT 'task',
    duration_minutes INT NOT NULL DEFAULT 30,
    scheduled_at    TIMESTAMPTZ,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    sort_order      INT NOT NULL DEFAULT 0,
    is_inbox        BOOLEAN NOT NULL DEFAULT FALSE,
    parent_task_id  UUID REFERENCES tasks(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    CONSTRAINT chk_task_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'PAUSED', 'COMPLETED', 'SKIPPED'))
);

CREATE INDEX idx_tasks_user_scheduled ON tasks(user_id, scheduled_at);
CREATE INDEX idx_tasks_user_inbox ON tasks(user_id, is_inbox) WHERE is_inbox = TRUE;
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);

CREATE TABLE routines (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    color       VARCHAR(7) NOT NULL DEFAULT '#6C63FF',
    icon        VARCHAR(50) NOT NULL DEFAULT 'routine',
    is_template BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE routine_steps (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    routine_id      UUID NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 15,
    color           VARCHAR(7) NOT NULL DEFAULT '#6C63FF',
    icon            VARCHAR(50) NOT NULL DEFAULT 'task',
    sort_order      INT NOT NULL DEFAULT 0
);

CREATE TABLE mood_entries (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mood        INT NOT NULL CHECK (mood BETWEEN 1 AND 5),
    energy      INT NOT NULL CHECK (energy BETWEEN 1 AND 5),
    notes       TEXT,
    recorded_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, recorded_at)
);
