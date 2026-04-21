-- Generated schema snapshot
-- Do not edit manually — run migrations to update the schema
--
-- To regenerate:
--   psql $DATABASE_URL -f database/migrations/0001_create_users.sql
--   psql $DATABASE_URL -f database/migrations/0002_create_accounts.sql
--   psql $DATABASE_URL -f database/migrations/0003_create_categories.sql
--   psql $DATABASE_URL -f database/migrations/0004_create_monthly_balances.sql
--   psql $DATABASE_URL -f database/migrations/0005_create_transactions.sql
--   psql $DATABASE_URL -f database/migrations/0006_create_budgets.sql
--   psql $DATABASE_URL -f database/seeds/dev_seed.sql

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE users (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email          TEXT         NOT NULL,
    password_hash  TEXT         NOT NULL,
    display_name   TEXT         NOT NULL
                                CONSTRAINT users_display_name_length
                                    CHECK (char_length(display_name) BETWEEN 1 AND 60),
    is_simple_view BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX users_email_idx ON users (lower(email));

-- ============================================================
-- TABLE: accounts
-- ============================================================
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

-- ============================================================
-- TABLE: categories
-- ============================================================
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

    CONSTRAINT categories_unique_name_per_scope
        UNIQUE NULLS NOT DISTINCT (user_id, name),

    CONSTRAINT categories_custom_requires_user
        CHECK (is_predefined = TRUE OR user_id IS NOT NULL)
);

CREATE INDEX categories_user_id_idx ON categories (user_id);
CREATE INDEX categories_predefined_idx ON categories (is_predefined)
    WHERE is_predefined = TRUE;

-- ============================================================
-- TABLE: monthly_balances
-- ============================================================
CREATE TABLE monthly_balances (
    id                UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
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
    expenditure       NUMERIC(12,2)  NOT NULL
                                     GENERATED ALWAYS AS (starting_balance - ending_balance) STORED,
    notes             TEXT,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT monthly_balances_unique_period
        UNIQUE (account_id, period_year, period_month)
);

CREATE INDEX monthly_balances_user_period_idx
    ON monthly_balances (user_id, period_year DESC, period_month DESC);
CREATE INDEX monthly_balances_account_id_idx ON monthly_balances (account_id);

-- ============================================================
-- TABLE: transactions
-- ============================================================
CREATE TABLE transactions (
    id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id       UUID           NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    category_id      UUID           NOT NULL REFERENCES categories(id),
    amount           NUMERIC(12,2)  NOT NULL
                                    CONSTRAINT transactions_amount_positive
                                        CHECK (amount > 0),
    description      TEXT,
    transaction_date DATE           NOT NULL,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT now()
);

CREATE INDEX transactions_user_date_idx
    ON transactions (user_id, transaction_date DESC);
CREATE INDEX transactions_category_date_idx
    ON transactions (category_id, transaction_date DESC);
CREATE INDEX transactions_account_id_idx ON transactions (account_id);

-- ============================================================
-- TABLE: budgets
-- ============================================================
CREATE TABLE budgets (
    id            UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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

    CONSTRAINT budgets_unique_goal_per_period
        UNIQUE NULLS NOT DISTINCT (user_id, category_id, period_year, period_month)
);

CREATE INDEX budgets_user_period_idx
    ON budgets (user_id, period_year DESC, period_month DESC);
CREATE INDEX budgets_category_idx ON budgets (category_id)
    WHERE category_id IS NOT NULL;
