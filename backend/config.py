import os
from pydantic import BaseSettings
from urllib.parse import quote_plus

class Settings(BaseSettings):
    # Database - updated with proper connection handling
    database_url: str = os.getenv("DATABASE_URL", "postgresql://postgres:070804@db.pqadpbxjnlxytomzmnwa.supabase.co :5432/postgres")
    
    # Add connection pool settings
    db_pool_size: int = 5
    db_max_overflow: int = 10
    db_pool_recycle: int = 3600
    
    @property
    def sqlalchemy_database_url(self):
        # Handle special characters in password
        if "@" in self.database_url:
            parts = self.database_url.split("@")
            user_pass, host = parts[0], parts[1]
            if "//" in user_pass:
                scheme, credentials = user_pass.split("//")
                credentials = quote_plus(credentials)
                return f"{scheme}//{credentials}@{host}"
        return self.database_url

    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

settings = Settings()