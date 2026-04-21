-- Migration 0004: Create monthly_balances table
-- Supports FR1: users input starting and ending balances per account per month.
-- Expenditure is auto-derived as a generated stored column.

CREATE TABLE monthly_balances (
    id                UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id denormalised from accounts to avoid join on the dashboard query
    user_id           UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id        UUID           NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    period_year       SMALLINT       NOT NULL
                                     CONSTRAINT monthly_balances_year_range
                                         CHECK (period_year BETWEEN 2000 AND 2100),
    period_month      SMALLINT       NOT NULL
                                     CONSTRAINT monthly_balances_month_range
                                         CHECK (period_month BETWEEN 1 AND 12),
    starting_balance  NUMERIC(12,2)  NOT NULL,
    ending_balance    NUMERIC(12,2)  NOT NULL,
    -- expenditure is always consistent and requires no application-layer calculation
    expenditure       NUMERIC(12,2)  NOT NULL
                                     GENERATED ALWAYS AS (starting_balance - ending_balance) STORED,
    notes             TEXT,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT monthly_balances_unique_period
        UNIQUE (account_id, period_year, period_month)
);

-- Dashboard loads balance by user + period
CREATE INDEX monthly_balances_user_period_idx
    ON monthly_balances (user_id, period_year DESC, period_month DESC);

CREATE INDEX monthly_balances_account_id_idx ON monthly_balances (account_id);
