-- Migration 0003: Add account_type, balance, monthly_budget, accent_color to accounts
-- These fields are required to map backend accounts to the frontend AccountModel.

ALTER TABLE accounts
  ADD COLUMN account_type   TEXT           NOT NULL DEFAULT 'current'
                            CONSTRAINT accounts_type_check
                                CHECK (account_type IN ('current', 'savings', 'joint')),
  ADD COLUMN balance        NUMERIC(12, 2) NOT NULL DEFAULT 0,
  ADD COLUMN monthly_budget NUMERIC(12, 2) NOT NULL DEFAULT 0,
  ADD COLUMN accent_color   BIGINT         NOT NULL DEFAULT 0;
