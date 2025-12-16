class UserProfile {
  final String id;
  final String email;
  final String username;

  UserProfile({required this.id, required this.email, required this.username});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'username': username};
  }
}

class ToyCar {
  final int id;
  final String userId;
  final String imageUrl;
  final String modelName;
  final String? comment;
  final bool isFavorite;

  ToyCar({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.modelName,
    this.comment,
    this.isFavorite = false,
  });

  factory ToyCar.fromJson(Map<String, dynamic> json) {
    return ToyCar(
      id: json['id'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      modelName: json['model_name'],
      comment: json['comment'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'image_url': imageUrl,
      'model_name': modelName,
      'comment': comment,
      'is_favorite': isFavorite,
    };
  }

  ToyCar copyWith({
    int? id,
    String? userId,
    String? imageUrl,
    String? modelName,
    String? comment,
    bool? isFavorite,
  }) {
    return ToyCar(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      modelName: modelName ?? this.modelName,
      comment: comment ?? this.comment,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
