# File: problem_metadata_dao.py
from models.data_model import ProblemMetadata
from utils.utils import JsonHelper
from services.database_service_singleton import DatabaseServiceSingleton
import pandas as pd

from pathlib import Path

BASE_DIR = Path(__file__).resolve()
while BASE_DIR.name != "python" and BASE_DIR != BASE_DIR.parent:
    BASE_DIR = BASE_DIR.parent



class ProblemMetadataDAO:
 
    # serialize the ProblemMetadata object anc call DB upsert
    @staticmethod
    def serialize_and_call_upsert(problem_metadata: ProblemMetadata) -> None:
        """
        Serializes a ProblemMetadata object and calls the database upsert method.

        Args:
            problem_metadata (ProblemMetadata): The metadata object
        """
        problem_metadata_serialized = JsonHelper.serialize_dict(problem_metadata)
        db = DatabaseServiceSingleton.get_instance()
        db.upsert_problem_metadata(problem_metadata_serialized)
    
    @staticmethod
    def is_hash_in_db(prob_id: str) -> bool:
        """
        Checks whether a given probID exists in the problem_metadata table.

        Args:
            prob_id (str): The SHA-1 hash of the problem string.

        Returns:
            bool: True if the probID exists in the database, False otherwise.
        """
        query = "SELECT 1 FROM problem_metadata WHERE probID = ? LIMIT 1"
        db = DatabaseServiceSingleton.get_instance()  # more on this below
        cursor = db.conn.cursor()
        result = cursor.execute(query, (prob_id,)).fetchone()
        return result is not None

    @staticmethod
    def build_ref_external_rank_table() -> None:
        df = pd.read_csv(BASE_DIR / "data" / "external_rank.csv")
        db = DatabaseServiceSingleton.get_instance()
        df.to_sql("ref_external_rank", db.conn, if_exists="replace", index=False)





