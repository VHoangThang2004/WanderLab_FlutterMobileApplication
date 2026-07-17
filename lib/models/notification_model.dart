class NotificationModel {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      message: map['message'],
      isRead: map['isRead'] == 1,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt,
    };
  }
}
