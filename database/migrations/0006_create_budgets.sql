-- Migration 0006: Create budgets table
-- Supports FR6: monthly spending goals per category and overall.
-- A row with category_id = NULL is the overall monthly goal
-- (maps to goalAmount in the dashboard mock data).

CREATE TABLE budgets (
    id            UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- NULL = overall monthly goal; set = per-category goal.
    -- No CASCADE: soft-delete categories rather than hard-delete.
    category_id   UUID           REFERENCES categories(id),
    period_year   SMALLINT       NOT NULL
                                 CONSTRAINT budgets_year_range
                                     CHECK (period_year BETWEEN 2000 AND 2100),
    period_month  SMALLINT       NOT NULL
                                 CONSTRAINT budgets_month_range
                                     CHECK (period_month BETWEEN 1 AND 12),
    goal_amount   NUMERIC(12,2)  NOT NULL
                                 CONSTRAINT budgets_amount_positive
                                     CHECK (goal_amount > 0),
    created_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),

    -- NULLS NOT DISTINCT ensures only one overall goal (category_id NULL)
    -- per user per month, alongside one goal per category per user per month.
    CONSTRAINT budgets_unique_goal_per_period
        UNIQUE NULLS NOT DISTINCT (user_id, category_id, period_year, period_month)
);

-- Dashboard loads goals alongside spending totals for the current period
CREATE INDEX budgets_user_period_idx
    ON budgets (user_id, period_year DESC, period_month DESC);

-- Partial index for per-category goal lookups
CREATE INDEX budgets_category_idx ON budgets (category_id)
    WHERE category_id IS NOT NULL;
