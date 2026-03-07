import uuid
from datetime import datetime, timezone


class Post:
    """Represents a lost-or-found item post."""

    def __init__(
        self,
        title: str,
        description: str,
        category: str,
        location: str,
        post_type: str,           # "lost" | "found"
        image_url: str | None = None,
        latitude: float | None = None,
        longitude: float | None = None,
    ):
        self.id = str(uuid.uuid4())
        self.title = title
        self.description = description
        self.category = category
        self.location = location
        self.type = post_type
        self.image_url = image_url
        self.latitude = latitude
        self.longitude = longitude
        self.created_at = datetime.now(timezone.utc).isoformat()

    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'category': self.category,
            'location': self.location,
            'type': self.type,
            'image_url': self.image_url,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'created_at': self.created_at,
        }
