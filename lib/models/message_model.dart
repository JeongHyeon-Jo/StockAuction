import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String uId;
  final String? otherUserId;
  final Timestamp createdAt;
  String? profileImageUrl;
  String? imageUrl;
  String? messageType;
  String? status; // (ready, deposit, shipping, dealed 등)
  Map<String, dynamic>? confirmationMessage;

  Message({
    required this.id,
    required this.text,
    required this.uId,
    this.otherUserId,
    required this.createdAt,
    this.profileImageUrl,
    this.imageUrl,
    this.messageType,
    this.status,
    this.confirmationMessage,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return Message(
      id: doc.id,
      text: data?['text'] ?? '',
      uId: data?['uId'] ?? '',
      otherUserId: data?['otherUserId'],
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      profileImageUrl: data?['profileImageUrl'],
      imageUrl: data?['imageUrl'],
      messageType: data?['messageType'],
      status: data?['status'],
      confirmationMessage: data?['confirmationMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'uId': uId,
      'otherUserId': otherUserId,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'imageUrl': imageUrl,
      'messageType': messageType,
      'status': status,
      'confirmationMessage': confirmationMessage,
    };
  }
}
