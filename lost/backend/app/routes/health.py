from flask import Blueprint, jsonify

health_bp = Blueprint('health', __name__)


@health_bp.route('/health', methods=['GET'])
# app.get('health',gethealth)
def health_check():
    """Health check — confirms the backend is running."""
    return jsonify({
        'status': 'ok',
        'message': 'Flask backend is running',
    }), 200
