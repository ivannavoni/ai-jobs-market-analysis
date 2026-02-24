import pandas as pd
import psycopg2
import io

# ─── Config ───────────────────────────────────────────────
DB_CONFIG = {
    "host": "localhost",
    "database": "postgres",
    "user": "postgres",
    "password": "password",
    "port": "5432"
}
CSV_PATH = "data/ai_job_dataset.csv"
# ──────────────────────────────────────────────────────────

df = pd.read_csv(CSV_PATH)
print(f"Loaded {len(df)} rows from CSV")

conn = psycopg2.connect(**DB_CONFIG)
cursor = conn.cursor()

cursor.execute("""
    CREATE TABLE IF NOT EXISTS ai_jobs (
        job_id TEXT,
        job_title TEXT,
        salary_usd INTEGER,
        salary_currency TEXT,
        salary_local INTEGER,
        experience_level TEXT,
        employment_type TEXT,
        company_location TEXT,
        company_size TEXT,
        employee_residence TEXT,
        remote_ratio INTEGER,
        required_skills TEXT,
        education_required TEXT,
        years_experience INTEGER,
        industry TEXT,
        posting_date TEXT,
        application_deadline TEXT,
        job_description_length INTEGER,
        benefits_score FLOAT,
        company_name TEXT
    )
""")

# Load into RAM as tab-separated string, then bulk copy into PostgreSQL
# Using io.StringIO avoids writing to disk — much faster for large datasets
output = io.StringIO()
df.to_csv(output, sep='\t', header=False, index=False)
output.seek(0)

try:
    cursor.copy_from(output, 'ai_jobs', sep='\t', null="")
    conn.commit()
    print("Raw data loaded successfully into ai_jobs")
except Exception as e:
    print(f"Error: {e}")
    conn.rollback()
finally:
    cursor.close()
    conn.close()
