# file: database_service_staging_singleton.py

from services.database_service import DatabaseService

class DatabaseServiceSingleton:
    _instance = None

    @classmethod
    def initialize(cls, db_path: str):
        if cls._instance is None:
            cls._instance = DatabaseService(db_path)

    @classmethod
    def get_instance(cls) -> DatabaseService:
        if cls._instance is None:
            raise Exception("DatabaseServiceSingleton has not been initialized.")
        return cls._instance
