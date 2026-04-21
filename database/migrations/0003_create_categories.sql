-- Migration 0003: Create categories table
-- Supports FR3: predefined system categories (user_id = NULL) and
-- user-created custom categories (user_id set).
-- Name must be 2–30 characters and unique within a user's scope.

CREATE TABLE categories (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        REFERENCES users(id) ON DELETE CASCADE,
    name          TEXT        NOT NULL
                              CONSTRAINT categories_name_length
                                  CHECK (char_length(name) BETWEEN 2 AND 30),
    icon          TEXT        NOT NULL DEFAULT 'category',
    colour_value  BIGINT      NOT NULL,
    is_predefined BOOLEAN     NOT NULL DEFAULT FALSE,
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- NULL user_id = predefined; NULLS NOT DISTINCT treats all NULLs as equal
    -- so predefined names are globally unique, and custom names are unique per user.
    CONSTRAINT categories_unique_name_per_scope
        UNIQUE NULLS NOT DISTINCT (user_id, name),

    -- Custom categories must have an owner
    CONSTRAINT categories_custom_requires_user
        CHECK (is_predefined = TRUE OR user_id IS NOT NULL)
);

CREATE INDEX categories_user_id_idx ON categories (user_id);

-- Partial index: predefined categories are fetched on every category picker load
CREATE INDEX categories_predefined_idx ON categories (is_predefined)
    WHERE is_predefined = TRUE;
