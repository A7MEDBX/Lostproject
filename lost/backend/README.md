# Lost & Found Backend

Flask REST API backend for the Lost & Found Flutter app.

## 🚀 Quick Start

### 1. First-time setup (creates venv + installs deps + starts server)

```bat
run.bat
```

### 2. Manual setup

```bash
cd lost/backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python run.py
```

Server starts on **http://0.0.0.0:5000**

## 📁 Project Structure

```
backend/
├── run.py                  # Entry point
├── config.py               # Dev / Prod configuration
├── requirements.txt
├── .env.example            # Copy to .env and fill in values
├── run.bat                 # Windows: setup + start
├── app/
│   ├── __init__.py         # App factory (create_app)
│   ├── models/
│   │   └── post.py         # Post data model
│   ├── routes/
│   │   ├── health.py       # GET /api/health
│   │   └── posts.py        # GET/POST /api/posts
│   └── services/
│       └── post_service.py # Business logic (swap in DB here)
└── temp_uploads/           # Saved uploaded images
```

## 🔌 API Endpoints

### Health Check

```http
GET /api/health
```

**Response:**

```json
{
  "status": "ok",
  "message": "Flask backend is running",
  "ai_model": "CLIP ViT-B/32",
  "device": "cpu",
  "vector_db": "Qdrant (local)",
  "total_posts": 5
}
```

### Create Post with AI Matching

```http
POST /api/posts/create-with-matching
Content-Type: multipart/form-data
```

**Form Data:**

- `image` (file) - Image of the lost/found item
- `title` (string) - Item title
- `description` (string) - Detailed description
- `category` (string) - Category (Wallet, Phone, Keys, Bag, etc.)
- `location` (string) - Location where item was lost/found
- `type` (string) - "lost" or "found"
- `latitude` (float, optional) - GPS latitude
- `longitude` (float, optional) - GPS longitude

**Response:**

```json
{
  "success": true,
  "post_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Post created successfully",
  "matches_count": 3,
  "matches": [
    {
      "id": "abc123",
      "title": "Black Leather Wallet",
      "description": "Found near Central Park...",
      "category": "Wallet",
      "location": "Central Park, NY",
      "distance": "2km away",
      "image_url": "http://localhost:5000/uploads/abc123_wallet.jpg",
      "post_type": "found",
      "match_percentage": 98.5,
      "time_ago": "2 hours ago",
      "finder_name": "User",
      "is_verified": false
    }
  ]
}
```

### Get All Posts

```http
GET /api/posts?type=lost&category=Wallet
```

**Query Parameters:**

- `type` (optional) - Filter by "lost" or "found"
- `category` (optional) - Filter by category

### Get Single Post

```http
GET /api/posts/{post_id}
```

## 🤖 How AI Matching Works

1. **Image Upload** - User uploads image of lost/found item
2. **Embedding Generation** - CLIP model generates 512-dimensional vector
3. **Vector Storage** - Embedding stored in Qdrant with metadata
4. **Similarity Search** - Search for similar embeddings (opposite type)
5. **Results Ranking** - Return matches sorted by similarity score (60%+ threshold)

### Technology Stack:

- **AI Model:** OpenAI CLIP (ViT-B/32) - pretrained, no training needed
- **Vector DB:** Qdrant (local file-based storage)
- **Image Storage:** Local filesystem (Firebase optional)
- **Similarity:** Cosine similarity in 512D space

## 🛠️ Configuration

### Firebase (Optional)

To enable Firebase Storage:

1. Create `firebase-credentials.json` in backend folder
2. Update `storage_service.py`:
   ```python
   self.use_firebase = True
   ```

### GPU Acceleration

CLIP will automatically use CUDA if available:

- CPU: ~2-3 seconds per image
- GPU: ~0.5 seconds per image

## 📊 Performance

- **Embedding Generation:** ~2 seconds (CPU), ~0.5s (GPU)
- **Vector Search:** <100ms for 1000s of items
- **Memory:** ~1GB RAM (CLIP model)
- **Storage:** ~1KB per embedding

## 🔍 Testing

### Test with curl:

```bash
curl -X POST http://localhost:5000/api/posts/create-with-matching \
  -F "image=@wallet.jpg" \
  -F "title=Black Wallet" \
  -F "description=Lost my black leather wallet" \
  -F "category=Wallet" \
  -F "location=Central Park" \
  -F "type=lost"
```

### Test with Flutter App:

1. Update `api_endpoints.dart` with your IP
2. Run app and create a post
3. Check backend console for logs

## 🐛 Troubleshooting

### Issue: `ModuleNotFoundError: No module named 'clip'`

**Solution:** Run `pip install git+https://github.com/openai/CLIP.git`

### Issue: CLIP model download fails

**Solution:** Download manually and place in `~/.cache/clip/`

### Issue: Port 5000 already in use

**Solution:** Change port in `app.py`: `app.run(port=5001)`

### Issue: CORS errors from Flutter

**Solution:** Restart Flask server, CORS is enabled by default

## 📝 Notes

- First run downloads CLIP model (~350MB)
- Qdrant data stored in `./qdrant_data/` folder
- Posts stored in memory (restart = data lost)
- For production: Add MongoDB for persistence

## 🚧 Future Enhancements

- [ ] MongoDB integration for persistence
- [ ] User authentication (JWT)
- [ ] Real distance calculation
- [ ] Firebase Storage integration
- [ ] WebSocket for real-time updates
- [ ] Admin dashboard
- [ ] Email notifications
