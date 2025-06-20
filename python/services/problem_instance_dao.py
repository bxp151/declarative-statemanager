# File: problem_instance_dao.py

from models.data_model import ProblemInstance
from utils.utils import JsonHelper
from services.database_service_singleton import DatabaseServiceSingleton


class ProblemInstanceDAO:
 
    @staticmethod
    def serialize_and_call_upsert(problem_instance: ProblemInstance) -> None:
        """
        Serializes a ProblemInstance object and calls the database upsert method.

        Args:
            problem_instance (ProblemInstance): The metadata object
        """
        problem_instance_serialized = JsonHelper.serialize_dict(problem_instance)
        db = DatabaseServiceSingleton.get_instance()
        db.upsert_problem_instance(problem_instance_serialized)
        