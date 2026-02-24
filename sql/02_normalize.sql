-- ============================================================
-- 02_normalize.sql
-- Normalizes the flat ai_jobs table into a relational schema
-- Run against: PostgreSQL (postgres database)
-- ============================================================


-- ── 1. companies ─────────────────────────────────────────
-- Extracts unique companies from ai_jobs.
-- DISTINCT prevents duplicate rows when the same company
-- appears in multiple job postings.

CREATE TABLE companies (
    company_id   SERIAL PRIMARY KEY,
    company_name TEXT,
    company_size TEXT,
    company_location TEXT
);

INSERT INTO companies (company_name, company_size, company_location)
SELECT DISTINCT company_name, company_size, company_location
FROM ai_jobs;


-- ── 2. jobs ──────────────────────────────────────────────
-- Master table. References companies via company_id (FK).
-- JOIN resolves company_name → company_id at insert time.

CREATE TABLE jobs (
    job_id           TEXT PRIMARY KEY,
    job_title        TEXT,
    salary_usd       INTEGER,
    experience_level TEXT,
    employment_type  TEXT,
    remote_ratio     INTEGER,
    industry         TEXT,
    company_id       INTEGER REFERENCES companies(company_id),
    posting_date     TEXT
);

INSERT INTO jobs (
    job_id, job_title, salary_usd, experience_level,
    employment_type, remote_ratio, industry, company_id, posting_date
)
SELECT DISTINCT
    a.job_id,
    a.job_title,
    a.salary_usd,
    a.experience_level,
    a.employment_type,
    a.remote_ratio,
    a.industry,
    c.company_id,
    a.posting_date
FROM ai_jobs a
JOIN companies c
    ON  a.company_name     = c.company_name
    AND a.company_size     = c.company_size
    AND a.company_location = c.company_location;


-- ── 3. skills ────────────────────────────────────────────
-- One row per skill per job.
-- string_to_array splits "Python, SQL, Docker" into an array.
-- unnest expands that array into individual rows.

CREATE TABLE skills (
    skill_id SERIAL PRIMARY KEY,
    job_id   TEXT REFERENCES jobs(job_id),
    skill    TEXT
);

INSERT INTO skills (job_id, skill)
SELECT DISTINCT
    job_id,
    trim(unnest(string_to_array(required_skills, ',')))
FROM ai_jobs
WHERE required_skills IS NOT NULL;


-- ── 4. education ─────────────────────────────────────────
-- One row per job with its education requirement.

CREATE TABLE education (
    education_id       SERIAL PRIMARY KEY,
    job_id             TEXT REFERENCES jobs(job_id),
    education_required TEXT
);

INSERT INTO education (job_id, education_required)
SELECT job_id, education_required
FROM ai_jobs
WHERE education_required IS NOT NULL;
