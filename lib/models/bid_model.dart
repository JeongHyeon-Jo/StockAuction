import 'package:auction/models/user_model.dart';

class BidModel {
  UserModel bidUser;
  DateTime bidTime;
  String bidPrice;

  BidModel({
    required this.bidUser,
    required this.bidTime,
    required this.bidPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'bidUser': bidUser.toMap(),
      'bidTime': bidTime.toIso8601String(),
      'bidPrice': bidPrice,
    };
  }

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      bidUser: UserModel.fromMap(map['bidUser']),
      bidTime: _parseDateTime(map['bidTime']),
      bidPrice: map['bidPrice'] ?? '',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}