# file: csv_export.py

import subprocess
import textwrap
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent
OUTPUT_PATH = BASE_DIR / "data" / "problem_tracking.csv"
DB_PATH = BASE_DIR / "data" / "problems.db"

commands = f""".headers on
.mode csv
.output {str(OUTPUT_PATH)}
SELECT instanceID, 0 AS timesServed, 0 AS lastServedTimestamp FROM problem_final;
.output stdout
"""

subprocess.run(['sqlite3', str(DB_PATH)], input=commands.encode())



