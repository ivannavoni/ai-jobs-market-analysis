-- ============================================================
-- 03_queries.sql
-- Analysis queries on the normalized schema
-- ============================================================


-- ── Q1: Top 10 most required skills ──────────────────────

SELECT skill, COUNT(skill)
FROM skills
GROUP BY skill
ORDER BY COUNT(skill) DESC
LIMIT 10;


-- ── Q2: Average salary by company location ───────────────

SELECT company_location, ROUND(AVG(salary_usd)) AS "Average salary usd"
FROM companies c
JOIN jobs j ON j.company_id = c.company_id
GROUP BY company_location
ORDER BY "Average salary usd" DESC
LIMIT 50;


-- ── Q3: Companies with the most job openings ─────────────

SELECT company_name, COUNT(job_id)
FROM companies c
JOIN jobs j ON j.company_id = c.company_id
GROUP BY company_name
ORDER BY COUNT(job_id) DESC;

-- ── Q4: Job count grouped by number of required skills ───
-- How many jobs require 1 skill, 2 skills, 3 skills, etc.

WITH skills_per_job AS (
    SELECT job_id, COUNT(*) AS skill_count
    FROM skills
    GROUP BY job_id
)
SELECT skill_count, COUNT(skill_count) AS job_count
FROM skills_per_job
GROUP BY skill_count
ORDER BY skill_count DESC;