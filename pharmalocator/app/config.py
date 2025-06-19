import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key')
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'sqlite:///pharmalocator.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # Add other config variables as needed

class DevConfig(Config):
    DEBUG = True

class ProdConfig(Config):
    DEBUG = False
