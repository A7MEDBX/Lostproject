/// User Entity - Domain Layer
/// Matches the backend /user/me response schema exactly.
class User {
  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String role; // 'user' | 'admin'
  final bool verified;
  final double trustScore;
  final String verificationStatus; // 'not_submitted' | 'pending' | 'approved' | 'rejected'
  final String? phoneNumber;
  final String? nationalId;
  final String? idImageUrl;
  final String? verificationNotes;
  final DateTime? verificationSubmittedAt;
  final DateTime? verificationReviewedAt;
  final DateTime createdAt;

  bool get isAdmin => role == 'admin';

  const User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.role,
    required this.verified,
    required this.trustScore,
    required this.verificationStatus,
    this.phoneNumber,
    this.nationalId,
    this.idImageUrl,
    this.verificationNotes,
    this.verificationSubmittedAt,
    this.verificationReviewedAt,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? name,
    String? role,
    bool? verified,
    double? trustScore,
    String? verificationStatus,
    String? phoneNumber,
    String? nationalId,
    String? idImageUrl,
    String? verificationNotes,
    DateTime? verificationSubmittedAt,
    DateTime? verificationReviewedAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      verified: verified ?? this.verified,
      trustScore: trustScore ?? this.trustScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verificationSubmittedAt:
          verificationSubmittedAt ?? this.verificationSubmittedAt,
      verificationReviewedAt:
          verificationReviewedAt ?? this.verificationReviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
