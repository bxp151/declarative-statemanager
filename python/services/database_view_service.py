from services.database_service_singleton import DatabaseServiceSingleton

class DatabaseViewService:
    @staticmethod
    def build_problem_view():
        db_service = DatabaseServiceSingleton.get_instance()
        db = db_service.conn
        cursor = db.cursor()
        cursor.execute("""
        CREATE VIEW IF NOT EXISTS problem_view AS
        SELECT 
            probID,
            carryMode,
            instanceID,
            probText,
            answer,
            DENSE_RANK() OVER (ORDER BY gradeLevel, subLevelScore) AS overallLevel,
            gradeLevel,
            subLevelScore,
            paramLevelScore,
            paramType,
            paramNum,
            numParameters,
            numSteps,
            stepHuman,
            stepMap,
            solvedGrid,
            paramGrid,
            stepsToParams
        FROM (
            SELECT 
                m.probID,
                i.carryMode,
                i.instanceID,
                m.gradeLevel,
                DENSE_RANK() OVER (
                    PARTITION BY m.gradeLevel 
                    ORDER BY i.carryMode ASC, m.subLevelScore
                ) AS subLevelScore,
                i.paramLevelScore,
                i.paramType,
                i.paramNum,
                i.numParameters,
                i.numSteps,
                m.probText,
                m.answer,
                m.stepHuman,
                m.stepMap,
                m.solvedGrid,
                i.paramGrid,
                i.stepsToParams
            FROM problem_metadata AS m
            JOIN problem_instance AS i ON m.probID = i.probID
        ) AS ranked
        ORDER BY gradeLevel, carryMode DESC, subLevelScore
        """)
        db.commit()

    @staticmethod
    def build_problem_by_overall_level_view():
        db_service = DatabaseServiceSingleton.get_instance()
        db = db_service.conn
        cursor = db.cursor()
        cursor.execute("""
        CREATE VIEW IF NOT EXISTS problem_by_overall_level_view AS
        WITH problem_view_subset AS (
            SELECT 
                instanceID,
                DENSE_RANK() OVER (
                    ORDER BY gradeLevel, subLevelScore
                ) AS overallLevel
            FROM (
                SELECT 
                    m.probID,
                    i.carryMode,
                    i.instanceID,
                    m.gradeLevel,
                    DENSE_RANK() OVER (
                        PARTITION BY m.gradeLevel 
                        ORDER BY i.carryMode DESC, m.subLevelScore
                    ) AS subLevelScore
                FROM problem_metadata AS m
                JOIN problem_instance AS i ON m.probID = i.probID
            ) AS ranked
        )
        SELECT 
            ROW_NUMBER() OVER (ORDER BY overallLevel) AS origRowNum,
            instanceID,
            overallLevel
        FROM problem_view_subset
        ORDER BY overallLevel;
        """)
        db.commit()
