-- Add username column to users table for username/password authentication.
-- Makes email nullable (no longer the primary login identifier).
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;

ALTER TABLE users
    ADD COLUMN username TEXT
        CONSTRAINT users_username_length CHECK (char_length(username) BETWEEN 3 AND 30);

-- Backfill existing rows from display_name.
UPDATE users SET username = display_name WHERE username IS NULL;

ALTER TABLE users ALTER COLUMN username SET NOT NULL;

CREATE UNIQUE INDEX users_username_idx ON users (lower(username));
