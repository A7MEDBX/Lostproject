import '../../domain/entities/post.dart';

/// Post Model - Data Layer (extends Entity)
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.category,
    required super.postType,
    required super.imageUrl,
    required super.country,
    super.state,
    super.city,
    super.latitude,
    super.longitude,
    super.location,
    required super.createdAt,
    super.updatedAt,
  });

  /// From JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      postType: json['post_type'] as String,
      imageUrl: json['image_url'] as String,
      country: json['country'] as String,
      state: json['state'] as String?,
      city: json['city'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'post_type': postType,
      'image_url': imageUrl,
      'country': country,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// From Entity
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      description: post.description,
      category: post.category,
      postType: post.postType,
      imageUrl: post.imageUrl,
      country: post.country,
      state: post.state,
      city: post.city,
      latitude: post.latitude,
      longitude: post.longitude,
      location: post.location,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    );
  }
}
