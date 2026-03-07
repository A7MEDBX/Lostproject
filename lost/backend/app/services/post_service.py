from app.models.post import Post

# In-memory store — swap out for a real database (SQLite / PostgreSQL) later.
_posts: dict[str, Post] = {}


class PostService:
    """Business logic for posts."""

    def get_all_posts(self) -> list[dict]:
        return [p.to_dict() for p in _posts.values()]

    def get_post_by_id(self, post_id: str) -> dict | None:
        post = _posts.get(post_id)
        return post.to_dict() if post else None

    def create_post(self, data: dict, image_url: str | None = None) -> dict:
        post = Post(
            title=data.get('title', ''),
            description=data.get('description', ''),
            category=data.get('category', ''),
            location=data.get('location', ''),
            post_type=data.get('type', 'lost'),
            image_url=image_url,
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
        )
        _posts[post.id] = post

        return {
            'post_id': post.id,
            'matches_count': 0,   # TODO: plug in AI matching service
            'matches': [],
            'post': post.to_dict(),
        }
