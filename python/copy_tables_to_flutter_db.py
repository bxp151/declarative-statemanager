
from pathlib import Path
import sys
import sqlite3
import subprocess


BASE_DIR = Path(__file__).resolve().parent

# Set DB Path
SOURCE_DB_PATH = str(BASE_DIR / "data" / "problems.db")


result = subprocess.run(
    'echo "$(xcrun simctl get_app_container booted com.example.automath data)/Documents/app_database.db"',
    shell=True,
    capture_output=True,
    text=True
)

DEST_DB_PATH = result.stdout.strip()
print(SOURCE_DB_PATH, DEST_DB_PATH)


# Connect to the python problems.db
conn = sqlite3.connect(SOURCE_DB_PATH)

# Attach the flutter app db to the problems.db
conn.execute(f"ATTACH DATABASE '{DEST_DB_PATH}' AS dest")


# # Copy the table from source to destination
conn.execute("CREATE TABLE dest.problem_final AS SELECT * FROM main.problem_final")
conn.execute("CREATE TABLE dest.problem_attempt_log AS SELECT * FROM main.problem_attempt_log")
conn.execute("CREATE TABLE dest.probid_stepnum_stepcalc AS SELECT * from main.probid_stepnum_stepcalc")
conn.execute("CREATE TABLE dest.grade_level_to_first_overall_level AS SELECT * from main.grade_level_to_first_overall_level")


conn.commit()
conn.close()
