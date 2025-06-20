# main.py

from services.database_service_singleton import DatabaseServiceSingleton
from services.database_table_service import DatabaseTableService
from generators.problem_generator import ProblemGenerator
from services.problem_metadata_dao import ProblemMetadataDAO
from pathlib import Path
from utils.utils import Utils
import subprocess
import sys


BASE_DIR = Path(__file__).resolve().parent

# Set DB Path
DB_PATH = BASE_DIR / "data" / "problems.db"

DatabaseServiceSingleton.initialize(str(DB_PATH))


def first_generation_steps():
    # 2 X 2 Problems
    gen = ProblemGenerator(
        problem_type= "+",
        max_operand_row_digits = 2, 
        operand_row_count = 2)

    gen.generate_problems_final()
    gen.split_problems_final_into_batches()
    gen.process_all_batches()
    gen.write_problems_to_file()

    # Build problem_view, problem_by_overall_level_view
    gen.build_problem_views()

def second_generation_steps():
    # 1 X 3 supporting set 
    gen = ProblemGenerator(
        problem_type= "+",
        max_operand_row_digits = 1, 
        operand_row_count = 3)

    gen.generate_problems_final()
    gen.split_problems_final_into_batches()
    gen.process_all_batches()
    gen.write_problems_to_file()

    # Build problem_view, problem_by_overall_level_view
    gen.build_problem_views()

    # ////////////////////////
    # always perform these last
    gen.build_problem_shuffle_index_table()
    db_service = DatabaseServiceSingleton().get_instance()
    db_service.populate_problem_final_table()
    db_service.populate_problem_attempt_log_table()

    # Build the table linking problem ID > steps > step Problem ID
    DatabaseTableService().build_probid_stepnum_stepcalc_table()
    DatabaseTableService().populate_grade_level_to_first_overall_level()

# Controllers
first_generation_steps()
second_generation_steps()