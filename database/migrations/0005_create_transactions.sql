-- Migration 0005: Create transactions table
-- Individual spending records supporting FR3 (categorisation), FR4 (ranked list),
-- FR5 (pie chart), and FR7 (time-based filtering).
-- This is the primary source for all category aggregations on the dashboard.

CREATE TABLE transactions (
    id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id denormalised from accounts to avoid a join on every dashboard query
    user_id          UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id       UUID           NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    -- No CASCADE: blocks hard-delete of categories that have transactions.
    -- Use is_active = FALSE on categories instead.
    category_id      UUID           NOT NULL REFERENCES categories(id),
    amount           NUMERIC(12,2)  NOT NULL
                                    CONSTRAINT transactions_amount_positive
                                        CHECK (amount > 0),
    description      TEXT,
    -- User-facing date of the spend; separate from created_at insertion timestamp.
    -- All FR7 time filters are applied against this column.
    transaction_date DATE           NOT NULL,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT now()
);

-- Most critical index: covers the dashboard aggregation query
-- WHERE user_id = ? AND transaction_date BETWEEN ? AND ?
CREATE INDEX transactions_user_date_idx
    ON transactions (user_id, transaction_date DESC);

-- Covers category drill-down queries
CREATE INDEX transactions_category_date_idx
    ON transactions (category_id, transaction_date DESC);

CREATE INDEX transactions_account_id_idx ON transactions (account_id);
