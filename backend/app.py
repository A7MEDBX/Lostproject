from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
from datetime import datetime
import uuid
from werkzeug.utils import secure_filename

from services.ai_service import AIService
from services.storage_service import StorageService
from services.vector_db_service import VectorDBService

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'temp_uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max

# Initialize services
ai_service = AIService()
storage_service = StorageService()
vector_db_service = VectorDBService()

# Static posts database - matches seeded vector DB data
posts_db = {
    'pink-wallet-001': {
        'id': 'pink-wallet-001',
        'title': 'Pink Quilted Wallet',
        'description': 'Found this beautiful pink wallet in Central Park near the fountain',
        'category': 'Wallet',
        'location': 'Central Park, NY',
        'post_type': 'found',
        'image_url': 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500',
        'coordinates': {'latitude': 40.7829, 'longitude': -73.9654},
        'created_at': '2024-12-19T17:25:00',
        'status': 'active'
    },
    'teddy-bear-002': {
        'id': 'teddy-bear-002',
        'title': 'Brown Teddy Bear',
        'description': 'Lost my child\'s favorite teddy bear at the library reading area',
        'category': 'Other',
        'location': 'Main Street Library',
        'post_type': 'lost',
        'image_url': 'https://images.unsplash.com/photo-1519897831810-a9a01aceccd1?w=500',
        'coordinates': {'latitude': 40.7580, 'longitude': -73.9855},
        'created_at': '2024-12-19T17:30:00',
        'status': 'active'
    },
    'leather-bag-003': {
        'id': 'leather-bag-003',
        'title': 'Leather Travel Pouch',
        'description': 'Found this brown leather bag at the airport terminal near gate B4',
        'category': 'Bag',
        'location': 'JFK Airport Terminal 4',
        'post_type': 'found',
        'image_url': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500',
        'coordinates': {'latitude': 40.6413, 'longitude': -73.7781},
        'created_at': '2024-12-19T17:20:00',
        'status': 'active'
    },
    'blue-backpack-004': {
        'id': 'blue-backpack-004',
        'title': 'Blue Backpack',
        'description': 'Found this blue backpack at the gym locker area',
        'category': 'Bag',
        'location': 'City Fitness Gym',
        'post_type': 'found',
        'image_url': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
        'coordinates': {'latitude': 40.7484, 'longitude': -73.9857},
        'created_at': '2024-12-19T17:15:00',
        'status': 'active'
    },
    'iphone-red-005': {
        'id': 'iphone-red-005',
        'title': 'iPhone with Red Case',
        'description': 'Lost my iPhone 13 with a red silicone case at the coffee shop',
        'category': 'Phone',
        'location': 'Starbucks Times Square',
        'post_type': 'lost',
        'image_url': 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=500',
        'coordinates': {'latitude': 40.7580, 'longitude': -73.9855},
        'created_at': '2024-12-19T17:35:00',
        'status': 'active'
    }
}


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'message': 'Flask backend is running',
        'ai_model': 'CLIP ViT-B/32',
        'device': ai_service.device,
        'vector_db': 'Qdrant (local)',
        'total_posts': len(posts_db)
    }), 200


@app.route('/api/posts/create-with-matching', methods=['POST'])
def create_post_with_matching():
    """
    DISABLED - Returns static matches only (no post creation)
    
    This endpoint now only performs AI matching against static data
    and returns demo results without actually creating any posts.
    """
    try:
        print("\n" + "="*60)
        print("📥 Received matching request (static mode)")
        print("="*60)
        
        # Validate image file
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Allowed: png, jpg, jpeg, webp'}), 400
        
        # Get form data
        post_type = request.form.get('type', 'lost').lower()
        category = request.form.get('category', '').strip()
        
        print(f"📝 Post Details:")
        print(f"   Type: {post_type}")
        print(f"   Category: {category}")
        
        # Generate unique ID for temp file
        post_id = str(uuid.uuid4())
        filename = secure_filename(f"{post_id}_{file.filename}")
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        
        # Save file temporarily
        file.save(file_path)
        print(f"💾 Saved temporary file: {filename}")
        
        # Generate AI embedding for matching only
        print(f"🤖 Generating AI embedding for matching...")
        embedding = ai_service.generate_embedding(file_path)
        print(f"✅ Embedding generated: {len(embedding)} dimensions")
        
        # Search for matches in existing static data with category filter
        if category:
            print(f"🔎 Searching for similar items in '{category}' category...")
        else:
            print(f"🔎 Searching for similar items in static database...")
        
        matches = vector_db_service.search_similar(
            embedding=embedding,
            post_type=post_type,
            category=category if category else None,
            top_k=10,
            min_similarity=0.60  # 80% minimum - high quality matches only
        )
        
        # Format matches with full post details
        matching_results = []
        print(f"📋 Processing {len(matches)} matches from vector DB...")
        for match in matches:
            print(f"   Checking match: post_id={match.get('post_id')}, similarity={match.get('similarity')*100:.1f}%")
            match_post = posts_db.get(match['post_id'])
            if match_post:
                print(f"   Found in posts_db: {match_post['title']} (category: {match_post.get('category')}, type: {match_post['post_type']})")
                # Double-check category matches if category was specified
                if category and match_post.get('category', '').lower() != category.lower():
                    print(f"   ⚠️  Skipping {match_post['title']} - wrong category ({match_post.get('category')} vs {category})")
                    continue
                # Calculate time ago
                created_at = datetime.fromisoformat(match_post['created_at'])
                time_diff = datetime.now() - created_at
                
                if time_diff.days > 0:
                    time_ago = f"{time_diff.days} day{'s' if time_diff.days > 1 else ''} ago"
                elif time_diff.seconds >= 3600:
                    hours = time_diff.seconds // 3600
                    time_ago = f"{hours} hour{'s' if hours > 1 else ''} ago"
                else:
                    minutes = time_diff.seconds // 60
                    time_ago = f"{minutes} minute{'s' if minutes > 1 else ''} ago"
                
                matching_results.append({
                    'id': match['post_id'],
                    'title': match_post['title'],
                    'description': match_post['description'],
                    'category': match_post['category'],
                    'location': match_post['location'],
                    'distance': '2km away',
                    'image_url': match_post['image_url'],
                    'post_type': match_post['post_type'],
                    'match_percentage': round(match['similarity'] * 100, 1),
                    'time_ago': time_ago,
                    'finder_name': 'User',
                    'is_verified': False
                })
                print(f"   ✅ Added to results: {match_post['title']}")
            else:
                print(f"   ❌ Post not found in posts_db: {match.get('post_id')}")
        
        print(f"✨ Returning {len(matching_results)} validated matches")
        print("="*60 + "\n")
        
        # Clean up temp file
        if os.path.exists(file_path):
            os.remove(file_path)
        
        return jsonify({
            'success': True,
            'post_id': post_id,
            'message': 'Post created successfully',
            'matches_count': len(matching_results),
            'matches': matching_results
        }), 201
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@app.route('/api/posts/<post_id>', methods=['GET'])
def get_post(post_id):
    """Get post details by ID"""
    post = posts_db.get(post_id)
    if not post:
        return jsonify({'error': 'Post not found'}), 404
    return jsonify(post), 200
@app.route('/', methods=['GET'])
def start():
    """Base endpoint to verify API is running"""
    return jsonify({
        'message': 'Lost & Found AI Backend is running',
        'endpoints': {
            '/api/health': 'Health check',
            '/api/posts/create-with-matching': 'Create post with AI matching (POST)',
            '/api/posts/<post_id>': 'Get post details by ID (GET)',
            '/api/posts': 'Get all posts with optional filters (GET)'
        }
    }), 200
@app.route('/api/posts', methods=['GET'])
def get_all_posts():
    """Get all posts with optional filters"""
    post_type = request.args.get('type')  # lost, found
    category = request.args.get('category')
    
    posts = list(posts_db.values())
    
    # Apply filters
    if post_type:
        posts = [p for p in posts if p['post_type'] == post_type.lower()]
    if category:
        posts = [p for p in posts if p['category'].lower() == category.lower()]
    
    # Sort by created_at (newest first)
    posts.sort(key=lambda x: x['created_at'], reverse=True)
    
    return jsonify({
        'posts': posts,
        'count': len(posts)
    }), 200


@app.route('/uploads/<filename>')
def serve_upload(filename):
    """Serve uploaded files for local testing"""
    return send_from_directory(UPLOAD_FOLDER, filename)


if __name__ == '__main__':
    print("\n" + "="*60)
    print("🚀 Lost & Found AI Backend")
    print("="*60)
    print(f"📍 Server: http://localhost:5000")
    print(f"🤖 AI Model: CLIP ViT-B/32")
    print(f"💻 Device: {ai_service.device}")
    print(f"🗄️  Vector DB: Qdrant (local)")
    print("="*60 + "\n")
    
    app.run(debug=True, host='0.0.0.0', port=5000, use_reloader=False)
