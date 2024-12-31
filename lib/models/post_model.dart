import 'package:auction/models/bid_model.dart';
import 'package:auction/models/comment_model.dart';
import 'package:auction/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuctionStatus { bidding,  successBidding, failBidding } // 경매 진행 상태
enum StockStatus { bidding, readySell, successSell, failedSell } // 물품의 상태

class PostModel {
  String postUid;
  UserModel writeUser;
  String postTitle;
  String postContent;
  DateTime createTime;
  DateTime endTime;
  List<String> postImageList;
  List<Map<String, dynamic>> favoriteList;
  List<CommentModel> commentList;
  List<BidModel> bidList;
  bool isDone;
  AuctionStatus auctionStatus;
  StockStatus stockStatus;
  String successBiddingUser;

  PostModel({
    required this.postUid,
    required this.writeUser,
    required this.postTitle,
    required this.postContent,
    required this.createTime,
    required this.endTime,
    required this.postImageList,
    List<Map<String, dynamic>>? favoriteList,
    List<CommentModel>? commentList,
    List<BidModel>? bidList,
    bool? isDone,
    this.auctionStatus = AuctionStatus.bidding,
    this.stockStatus = StockStatus.bidding,
    this.successBiddingUser = "",
  })
      : favoriteList = favoriteList ?? [],
        commentList = commentList ?? [],
        bidList = bidList ?? [],
        isDone = isDone ?? false;

  // Convert PostModel to Map
  Map<String, dynamic> toMap() {
    return {
      'postUid': postUid,
      'writeUser': writeUser.toMap(),
      'postTitle': postTitle,
      'postContent': postContent,
      'createTime': Timestamp.fromDate(createTime),
      'endTime': Timestamp.fromDate(endTime),
      'postImageList': postImageList,
      'favoriteList': favoriteList,
      'commentList': commentList.map((comment) => comment.toMap()).toList(),
      'bidList': bidList.map((bid) => bid.toMap()).toList(),
      'isDone': isDone,
      'auctionStatus': auctionStatus.index,
      'stockStatus': stockStatus.index,
      'successBiddingUser': successBiddingUser,
    };
  }

  // Create a PostModel from Map
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postUid: map['postUid'] ?? '',
      writeUser: UserModel.fromMap(map['writeUser']),
      postTitle: map['postTitle'] ?? '',
      postContent: map['postContent'] ?? '',
      createTime: (map['createTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      postImageList: List<String>.from(map['postImageList'] ?? []),
      favoriteList: List<Map<String, dynamic>>.from(map['favoriteList'] ?? []),
      commentList: (map['commentList'] as List<dynamic>?)
          ?.map((commentMap) => CommentModel.fromMap(commentMap))
          .toList() ??
          [],
      bidList: (map['bidList'] as List<dynamic>?)
          ?.map((bidMap) => BidModel.fromMap(bidMap))
          .toList() ??
          [],
      isDone: map['isDone'] ?? false,
      auctionStatus: AuctionStatus.values[map['auctionStatus'] ?? 0],
      stockStatus: StockStatus.values[map['stockStatus'] ?? 0],
      successBiddingUser: map['successBiddingUser'] ?? '',
    );
  }

  // Helper method to check if a user has favorited this post
  bool isFavoritedBy(String userId) {
    return favoriteList.any((user) => user['uid'] == userId);
  }

  // Helper method to add a user to favorites
  void addToFavorites(UserModel user) {
    if (!isFavoritedBy(user.uid)) {
      favoriteList.add(user.toMap());
    }
  }

  // Helper method to remove a user from favorites
  void removeFromFavorites(String userId) {
    favoriteList.removeWhere((userMap) => userMap['uid'] == userId);
  }
}