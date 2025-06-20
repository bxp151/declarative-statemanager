import json
import hashlib
from models.data_model import ProblemMetadata, ProblemInstance
from services.database_service_singleton import DatabaseServiceSingleton
import pandas as pd
from services.database_service import DatabaseService


class JsonHelper:
    @staticmethod
    def serialize(obj):
        return json.dumps(obj)

    @staticmethod
    def deserialize(json_str):
        return json.loads(json_str)
    
    @staticmethod
    def serialize_dict(value: ProblemInstance | ProblemMetadata) -> dict:
        """
        Serializes any nested dict fields into JSON strings.
        Returns a flat dictionary ready for DB insertion.
        """
        serialized_dict = {}

        for key, val in value.__dict__.items():
            if isinstance(val, dict):
                serialized_dict[key] = json.dumps(val)
            else:
                serialized_dict[key] = val

        return serialized_dict




class Utils:
    # Generates and returns hashes for a problem string
    @staticmethod
    def generate_sha1(problem_string: str, size: int = 10) -> str:
        """
        Generates a SHA-1 hash from a given problem string.

        Args:
            problem_string (str): A string representation of the problem.

        Returns:
            str: A SHA-1 hash used to check uniqueness in the database.
        """
        hash_obj = hashlib.sha1(problem_string.encode('utf-8'))
        return hash_obj.hexdigest()[:size]
    
    @staticmethod
    def parse_grade_level(grade_level: str) -> tuple[int, int]:
        """
        Parses a grade level string in the format 'GXX.YY' (e.g., 'G01.07') into integers.

        Args:
            grade_level: A string representing the grade and level, prefixed with 'G' 
                        and separated by a period.

        Returns:
            A tuple (grade_num, level_num) where both are integers.
        """
        left, right = grade_level.split(".")
        grade_num = int(left.lstrip("G"))
        level_num = int(right)
        return grade_num, level_num

