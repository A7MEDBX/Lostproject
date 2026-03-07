import os
from flask import Flask
from flask_cors import CORS
from config import config


def create_app(config_name: str = 'default') -> Flask:
    """Flask application factory."""
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    # Enable CORS for all origins (restrict in production via env)
    CORS(app)

    # Ensure upload folder exists
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

    # Register blueprints
    from app.routes.health import health_bp
    from app.routes.posts import posts_bp

    app.register_blueprint(health_bp, url_prefix='/api')
    app.register_blueprint(posts_bp, url_prefix='/api')

    return app
