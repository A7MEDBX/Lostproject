import os
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
from app.services.post_service import PostService

posts_bp = Blueprint('posts', __name__)
post_service = PostService()


def _allowed_file(filename: str) -> bool:
    allowed = current_app.config['ALLOWED_EXTENSIONS']
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed


# ------------------------------------------------------------------
# GET /api/posts
# ------------------------------------------------------------------
@posts_bp.route('/posts', methods=['GET'])
def get_all_posts():
    """Return all posts."""
    return jsonify(post_service.get_all_posts()), 200


# ------------------------------------------------------------------
# GET /api/posts/<id>
# ------------------------------------------------------------------
@posts_bp.route('/posts/<string:post_id>', methods=['GET'])
def get_post(post_id: str):
    """Return a single post by ID."""
    post = post_service.get_post_by_id(post_id)
    if not post:
        return jsonify({'error': 'Post not found'}), 404
    return jsonify(post), 200


# ------------------------------------------------------------------
# POST /api/posts/create-with-matching
# ------------------------------------------------------------------
@posts_bp.route('/posts/create-with-matching', methods=['POST'])
def create_post_with_matching():
    """
    Create a new post.

    Form fields:
        image       (file)   – image of the item
        title       (str)
        description (str)
        category    (str)    – e.g. Wallet, Phone, Bag …
        location    (str)
        type        (str)    – "lost" or "found"
        latitude    (float, optional)
        longitude   (float, optional)
    """
    # --- validate image ---
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if not _allowed_file(file.filename):
        return jsonify({
            'error': 'Invalid file type. Allowed: png, jpg, jpeg, webp'
        }), 400

    # --- save image ---
    filename = secure_filename(file.filename)
    upload_folder = current_app.config['UPLOAD_FOLDER']
    image_path = os.path.join(upload_folder, filename)
    file.save(image_path)

    # --- create post ---
    data = request.form.to_dict()
    result = post_service.create_post(data, image_url=image_path)
    return jsonify(result), 201
