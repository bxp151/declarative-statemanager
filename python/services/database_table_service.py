import pandas as pd
import json
from services.database_service_singleton import DatabaseServiceSingleton

class DatabaseTableService:
    @staticmethod
    def build_problem_shuffle_index_table():
        db_service = DatabaseServiceSingleton.get_instance()
        db_conn = db_service.conn

        row_num_offset = 0
        distinct_levels = db_service.get_distinct_overall_levels()

        for level in distinct_levels:
            df = db_service.get_problem_by_overall_level(overallLevel=level)

            df = df.sample(frac=1, random_state=level).reset_index(drop=True)
            df['newRowNum'] = df.index + row_num_offset
            row_num_offset += len(df.index)

            df.to_sql('problem_shuffle_index', db_conn, if_exists='append', index=False)


    @staticmethod
    def extract_calculation_log(row) -> str:
        """
        Extracts the 'calculation_log' string from a stepHuman dictionary using stepNum as the key.

        This function is intended to be used with pandas DataFrame rows where:
        - 'stepHuman' is a dictionary mapping step numbers (as strings) to step metadata dictionaries.
        - 'stepNum' is an integer or string that identifies which step to extract.

        Returns:
            The 'calculation_log' value 
        """
        step_human = row['stepHuman']
        step_num_str = str(row['stepNum'])
        step_data = step_human[step_num_str]
        return step_data['calculation_log']


    @staticmethod
    def build_probid_stepnum_stepcalc_table() -> None:
        """
        Creates or replaces the 'probid_stepnum_stepcalc' table.

        Each row includes:
            - probID: problem identifier
            - stepNum: step index
            - stepCalc: extracted calculation log for the step
        """
        db_service = DatabaseServiceSingleton.get_instance()
        db_conn = db_service.conn

        df = db_service.get_distinct_prob_id_and_human_steps()
        df['stepHuman'] = df['stepHuman'].apply(json.loads)
        df['stepCalc'] = df.apply(DatabaseTableService.extract_calculation_log, axis=1)

        # Remove stepHuman column
        df.drop(columns=['stepHuman'], inplace=True)

        df.to_sql('probid_stepnum_stepcalc', db_conn, if_exists='append', index=False)

    @staticmethod
    def populate_grade_level_to_first_overall_level() -> None:
        """
        Populates the grade_level_to_first_overall_level table with the lowest
        overallLevel for each gradeLevel from the problem_final table.
        """
        db_service = DatabaseServiceSingleton.get_instance()
        db_conn = db_service.conn
        cursor = db_conn.cursor()

        cursor.execute("""
        INSERT INTO grade_level_to_first_overall_level
        WITH numbered_rows AS (
            SELECT gradeLevel,
                overallLevel,
                ROW_NUMBER() OVER (PARTITION BY gradeLevel ORDER BY overallLevel ASC) AS rn
            FROM problem_final
        )
        SELECT gradeLevel,
            overallLevel
        FROM numbered_rows
        WHERE rn = 1;
        """)
        
        db_conn.commit()