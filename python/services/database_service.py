# File: database_service.py

import sqlite3
import os
import pandas as pd
import subprocess
import textwrap

class DatabaseService:
    """
    Manages the lifecycle and connection of a local SQLite database for storing structured math problem data.

    Methods:
        __init__(db_path: str):
            Initializes the service by assigning the database path, conditionally creating the database,
            and opening a connection.

        create_database():
            Creates the database file and initializes required schema, including tables:
            - problem_metadata:
            - problem_instance: 
    """

      # Initialize the class and its attributes
    def __init__(self, db_path):
        """
        Initializes the DatabaseManager with the given database path.

        Args:
            db_path (str): The file path to the SQLite database.
        """
        self.db_path = db_path
        self.conn = sqlite3.connect(self.db_path)
        self.create_database()


    def create_database(self):
    
        """
        Creates the SQLite tables for problem_metadata and problem_instance.
        """
        cursor = self.conn.cursor()

        # Create problem_metadata and problem_instance tables using exact DB field names
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS problem_metadata (
            probID TEXT PRIMARY KEY,                -- First 10 digits of SHA-1
            problemStructureID TEXT NOT NULL,       -- SHA-1 of digits-addends-carry
            probText TEXT NOT NULL,                 -- Problem string with spaces
            answer REAL NOT NULL,                   -- Problem answer
            gradeLevel INT NOT NULL,                -- The grade level for the problem
            subLevelScore REAL NOT NULL,            -- The subLevel based on the problem attributes
            stepHuman TEXT NOT NULL,                -- Human readable steps and feedback (JSON)
            stepMap TEXT NOT NULL,                  -- Mapping of steps to grid positions (JSON)
            solvedGrid TEXT NOT NULL                -- Fully solved grid (JSON)
        );
        """)

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS problem_instance (
            instanceID TEXT PRIMARY KEY,            -- probID_paramType_numParameters
            probID TEXT NOT NULL,                   -- First 10 digits of SHA-1
            paramType TEXT NOT NULL,                -- Type of problem
            paramNum TEXT NOT NULL,                 -- The numbered ID for the param type
            numParameters INT NOT NULL,             -- Number of values to solve for
            paramLevelScore INT NOT NULL,           -- The paramLevel based on the parameterization
            numSteps INTEGER,                       -- Number of problem steps
            paramGrid TEXT NOT NULL,                -- Grid with parameters for solving (JSON)
            stepsToParams TEXT NOT NULL,            -- Map of steps to parameters (JSON)
            carryMode TEXT NOT NULL,                -- Set to 'exposed'
            FOREIGN KEY (probID) REFERENCES problem_metadata(probID)
        )
        """)

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS problem_final (
            probID TEXT NOT NULL,
            carryMode TEXT NOT NULL,
            instanceID TEXT PRIMARY KEY NOT NULL,
            probText TEXT NOT NULL,
            answer REAL NOT NULL,
            overallLevel INT NOT NULL,
            gradeLevel INT NOT NULL,
            subLevelScore INT NOT NULL,
            paramLevelScore INT NOT NULL,
            paramType TEXT NOT NULL,
            paramNum TEXT NOT NULL,
            numParameters INT NOT NULL,
            numSteps INT NOT NULL,
            stepHuman TEXT NOT NULL,
            stepMap TEXT NOT NULL,
            solvedGrid TEXT NOT NULL,
            paramGrid TEXT NOT NULL,
            stepsToParams TEXT NOT NULL
        );
        """)

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS problem_attempt_log (
            instanceID TEXT PRIMARY KEY,                    
            numTimesCompleted INT NOT NULL,    
            lastServedTimestamp INTEGER NOT NULL                    
        );
        """)

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS grade_level_to_first_overall_level (
            gradeLevel INT PRIMARY KEY,                    
            overallLevel INT NOT NULL   
        );
        """)


    def populate_problem_final_table(self) -> None:
        """
        Joins shuffled indices with full problem data to prepare the final problem table.
        """
        cursor = self.conn.cursor()

        cursor.execute("""
        INSERT INTO problem_final
        SELECT v.*
        FROM problem_shuffle_index AS i
            JOIN
            problem_view AS v ON i.instanceID = v.instanceID
        ORDER BY overallLevel, paramLevelScore
        """)

        self.conn.commit()

    def populate_problem_attempt_log_table(self) -> None:
        """
        Populates the problem_attempt_log table using the problem_final table
        as the source of truth
        """
        cursor = self.conn.cursor()

        cursor.execute("""
        INSERT INTO problem_attempt_log
        SELECT instanceID, 
               0 AS numTimesCompleted, 
               (strftime('%s', 'now') * 1000) AS lastServedTimestamp 
        FROM problem_final
        """)

        self.conn.commit()

    def drop_all_tables_except_problem_final(self) -> None:
        """
        Drops all tables and views except problem_final table
        """
        cursor = self.conn.cursor()

        statements = [
            "DROP TABLE IF EXISTS problem_instance;",
            "DROP TABLE IF EXISTS problem_metadata;",
            "DROP TABLE IF EXISTS problem_shuffle_index;",
            "DROP VIEW IF EXISTS problem_by_overall_level_view;",
            "DROP VIEW IF EXISTS problem_view;"
        ]

        for stmt in statements:
            cursor.execute(stmt)

        self.conn.commit()


    def upsert_problem_metadata(self, problem_metadata_row: dict) -> None:
        """
        Inserts or updates a row in the problem_metadata table using values from a dictionary.

        Args:
            problem_metadata_row (dict): Must contain:
                - 'probID'
                - 'probText'
                - 'gradeLevel'
                - 'stepHuman'
                - 'stepMap'
                - 'solvedGrid'
        """
        cursor = self.conn.cursor()

        cursor.execute("""
            INSERT INTO problem_metadata(probID, problemStructureID, probText, answer, gradeLevel, subLevelScore, stepHuman, stepMap, solvedGrid)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(probID) DO UPDATE SET
                probText = excluded.probText,
                problemStructureID = excluded.problemStructureID,
                answer = excluded.answer,
                gradeLevel = excluded.gradeLevel,
                subLevelScore = excluded.subLevelScore,
                stepHuman = excluded.stepHuman,
                stepMap = excluded.stepMap,
                solvedGrid = excluded.solvedGrid
        """, (
            problem_metadata_row['probID'],
            problem_metadata_row['problemStructureID'],
            problem_metadata_row['probText'],
            problem_metadata_row['answer'],
            problem_metadata_row['gradeLevel'],
            problem_metadata_row['subLevelScore'],
            problem_metadata_row['stepHuman'],
            problem_metadata_row['stepMap'],
            problem_metadata_row['solvedGrid']
        ))
        self.conn.commit()

    def upsert_problem_instance(self, problem_instance_row: dict) -> None:
        cursor = self.conn.cursor()

        cursor.execute("""
            INSERT INTO problem_instance(
                instanceID, probID,
                paramType, paramNum, numParameters, paramLevelScore,numSteps,
                paramGrid, stepsToParams, carryMode
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(instanceID) DO UPDATE SET
                probID = excluded.probID,
                paramType = excluded.paramType,
                paramNum = excluded.paramNum,
                numParameters = excluded.numParameters,
                paramLevelScore = excluded.paramLevelScore,
                numSteps = excluded.numSteps,
                paramGrid = excluded.paramGrid,
                stepsToParams = excluded.stepsToParams,
                carryMode = excluded.carryMode
        """, (
            problem_instance_row['instanceID'],
            problem_instance_row['probID'],
            problem_instance_row['paramType'],
            problem_instance_row['paramNum'],
            problem_instance_row['numParameters'],
            problem_instance_row['paramLevelScore'],
            problem_instance_row['numSteps'],
            problem_instance_row['paramGrid'],
            problem_instance_row['stepsToParams'],
            problem_instance_row['carryMode']
        ))
        self.conn.commit()



    def get_problem_by_overall_level(self, overallLevel: int) -> pd.DataFrame:
        """
        Retrieves a dataframe for all problems matching the given overallLevel.
        """
        return pd.read_sql_query(
            "SELECT * FROM problem_by_overall_level_view WHERE overallLevel = ?",
            self.conn,
            params=[overallLevel]
        )


    def get_distinct_overall_levels(self) -> list:
        """
        Returns a list of all distinct overallLevel values from the problem view.
        """
        df = pd.read_sql_query(
            "SELECT distinct(overallLevel) FROM problem_by_overall_level_view",
            self.conn)
        return list(df['overallLevel'])


    def get_distinct_prob_id_and_human_steps(self) -> pd.DataFrame:
        """
        """
        conn = self.conn

        query = """
        WITH RECURSIVE step_expansion AS (-- Base case
            SELECT DISTINCT probID,
                            numSteps,
                            stepHuman,
                            1 AS stepIndex
            FROM problem_final
            WHERE paramType = 'full'
            UNION ALL-- Recursive case
            SELECT probID,
                numSteps,
                stepHuman,
                stepIndex + 1
            FROM step_expansion
            WHERE stepIndex + 1 <= numSteps-- increment the step index until FALSE
        )
        SELECT probID,
            stepIndex AS stepNum,
            stepHuman
        FROM step_expansion
        ORDER BY probID,
                stepIndex
        """

        return pd.read_sql_query(query, conn)


