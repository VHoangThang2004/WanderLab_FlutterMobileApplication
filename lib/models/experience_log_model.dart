class ExperienceLog {
  final int? id;
  final int userId;
  final int destinationId;
  final String title;
  final String content;
  final double rating;
  final String? imageUrl;
  final String createdAt;

  // Helper fields for UI display populated via database join queries
  final String? userName;
  final String? destinationName;

  ExperienceLog({
    this.id,
    required this.userId,
    required this.destinationId,
    required this.title,
    required this.content,
    required this.rating,
    this.imageUrl,
    required this.createdAt,
    this.userName,
    this.destinationName,
  });

  factory ExperienceLog.fromMap(Map<String, dynamic> map) {
    return ExperienceLog(
      id: map['id'],
      userId: map['userId'],
      destinationId: map['destinationId'],
      title: map['title'],
      content: map['content'],
      rating: (map['rating'] as num).toDouble(),
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'],
      userName: map['userName'] ?? map['fullName'], // fallback for user table join
      destinationName: map['destinationName'] ?? map['name'], // fallback for destination table join
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destinationId': destinationId,
      'title': title,
      'content': content,
      'rating': rating,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
