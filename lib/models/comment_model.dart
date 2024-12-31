class CommentModel {
  final String id; // 새로운 고유 식별자
  final String uid;
  final String userProfileImage;
  final String userName;
  final String comment;
  final DateTime commentTime;

  CommentModel({
    required this.id,
    required this.uid,
    required this.userProfileImage,
    required this.userName,
    required this.comment,
    required this.commentTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'userProfileImage': userProfileImage,
      'userName': userName,
      'comment': comment,
      'commentTime': commentTime.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      userName: map['userName'] ?? '',
      comment: map['comment'] ?? '',
      commentTime: DateTime.parse(map['commentTime']),
    );
  }

  CommentModel copyWith({
    String? id,
    String? uid,
    String? userProfileImage,
    String? userName,
    String? comment,
    DateTime? commentTime,
  }) {
    return CommentModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      commentTime: commentTime ?? this.commentTime,
    );
  }
}