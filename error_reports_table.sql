-- ============================================================
-- error_report table
-- Stores user-submitted bug/error reports from the app.
-- Separate from the "report" table which holds generated reports.
-- Run this in your Supabase SQL Editor.
-- ============================================================

CREATE TABLE IF NOT EXISTS error_report (
  error_report_id   VARCHAR(64)   PRIMARY KEY,

  -- Who submitted it
  user_id           VARCHAR(64)   NOT NULL
                    REFERENCES "user"(user_id) ON DELETE CASCADE,

  -- Report content
  subject           VARCHAR(255)  NOT NULL,
  message           TEXT          NOT NULL,

  -- Workflow status
  status            VARCHAR(32)   NOT NULL DEFAULT 'Pending'
                    CHECK (status IN ('Pending', 'In Progress', 'Resolved', 'Closed')),

  -- Optional admin response
  admin_notes       TEXT,
  resolved_at       TIMESTAMP WITH TIME ZONE,

  -- Metadata
  submitted_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  app_version       VARCHAR(32),
  device_info       TEXT          -- e.g. "Chrome 120 / Windows 11"
);

-- Index for querying by user
CREATE INDEX IF NOT EXISTS idx_error_report_user_id
  ON error_report(user_id);

-- Index for admin dashboard (status filtering)
CREATE INDEX IF NOT EXISTS idx_error_report_status
  ON error_report(status);

-- Index for chronological listing
CREATE INDEX IF NOT EXISTS idx_error_report_submitted_at
  ON error_report(submitted_at DESC);
