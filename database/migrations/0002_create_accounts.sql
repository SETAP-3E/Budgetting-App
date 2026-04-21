-- Migration 0002: Create accounts table
-- Named bank/cash accounts owned by a user.
-- All balance inputs (FR1) and transactions (FR3–FR5) belong to an account.

CREATE TABLE accounts (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name         TEXT        NOT NULL
                             CONSTRAINT accounts_name_length
                                 CHECK (char_length(name) BETWEEN 1 AND 60),
    currency     CHAR(3)     NOT NULL DEFAULT 'GBP',
    is_active    BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT accounts_unique_name_per_user UNIQUE (user_id, name)
);

CREATE INDEX accounts_user_id_idx ON accounts (user_id);
