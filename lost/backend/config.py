import os


class Config:
    DEBUG = False
    TESTING = False
    UPLOAD_FOLDER = 'temp_uploads'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16 MB
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
    SECRET_KEY = os.getenv('SECRET_KEY', 'change-me-in-production')


class DevelopmentConfig(Config):
    DEBUG = True


class ProductionConfig(Config):
    DEBUG = False


config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig,
}
