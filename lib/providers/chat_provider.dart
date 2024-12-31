import 'package:auction/utils/function_method.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auction/models/message_model.dart';
import 'package:auction/models/post_model.dart';
import 'package:auction/models/bid_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'dart:io';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _currentChatId;
  String? _currentUserId;
  String? _currentUsername;

  List<Message> _messages = [];

  // getters
  String get currentChatId => _currentChatId ?? '';
  String get currentUserId => _currentUserId ?? '';
  String get currentUsername => _currentUsername ?? '';
  List<Message> get messages => _messages;

  void setCurrentChatInfo(String chatId, String userId, String username) {
    _currentChatId = chatId;
    _currentUserId = userId;
    _currentUsername = username;
  }

  // 거래확정 버튼 관련 함수 분류
  //////////////////////////////////////////////////////////////////////////////////////////////

  // 특정 조건을 만족하는 Post들을 가져오는 함수
  Future<List<PostModel>> fetchConfirmablePosts(String userId, String otherUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('writeUser.uid', isEqualTo: userId)
          .where('auctionStatus', isEqualTo: AuctionStatus.successBidding.index)
          .where('stockStatus', isEqualTo: StockStatus.readySell.index)
          .get();

      List<PostModel> confirmablePosts = querySnapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data() as Map<String, dynamic>);
      }).where((post) {
        return post.bidList.any((bid) => bid.bidUser.uid == otherUserId);
      }).toList();

      return confirmablePosts;
    } catch (e) {
      print("조건에 맞는 포스트를 불러오지 못함: $e");
      return [];
    }
  }

  // 거래 확정 메시지 보내기
  Future<void> sendConfirmationMessage(PostModel post, String chatId, String userId, String otherUserId, String username) async {
    try {
      await _ensureChatRoomExists(chatId, userId, otherUserId, username, '');

      final querySnapshot = await _firestore.collection('chats').doc(chatId).collection('messages')
      .where('messageType', isEqualTo: 'purchaseConfirmation')
      .where('status', whereIn: ['ready', 'deposit', 'shipping'])
      .where('confirmationMessage.postUid', isEqualTo: post.postUid)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();

      String currentStatus = 'ready';
      if (querySnapshot.docs.isNotEmpty) {
        currentStatus = querySnapshot.docs.first.data()['status'];
      }

      if(currentStatus == 'canceled') currentStatus = 'ready';

      BidModel? highestBid = post.bidList
          .where((bid) => bid.bidUser.uid == otherUserId)
          .reduce((current, next) => current.bidTime.isAfter(next.bidTime) ? current : next);

      String bidPrice = highestBid != null ? highestBid.bidPrice : '0';

      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'text': '[거래를 완료해주세요]',
        'uId': userId,
        'username': username,
        'createdAt': Timestamp.now(),
        'imageUrl': post.postImageList.isNotEmpty ? post.postImageList[0] : null,
        'confirmationMessage': {
          'postUid': post.postUid,
          'title': post.postTitle,
          'bidPrice': bidPrice,
          'postContent': post.postContent.length > 50 
              ? '${post.postContent.substring(0, 50)}...' 
              : post.postContent,
          'status': currentStatus,
          'buttons': ['확인', '취소']
        },
        'messageType': 'purchaseConfirmation',
        'status': currentStatus,
      });

      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
      await chatRef.update({
        'lastActivityTime': Timestamp.now(),
        'lastMessage': '[거래를 완료해주세요]',
      });

      notifyListeners();
      //채팅방 아이디와 같이 푸시알림
      final ids = [userId, otherUserId];
      ids.sort();
      final chatRoomId = ids.join('_');
      sendNotification(title: "알림",
        body: "${post.postTitle} 상품의 거래 확정 메시지가 도착했습니다.",
        pushToken: post.bidList.last.bidUser.pushToken ?? "",
        screen: "/chat/$chatRoomId"
      );
    } catch (e) {
      print("확정 메시지 보내기에서 에러가 떴음: $e, chatId: $chatId, postUid: ${post.postUid}");
    }
  }

  // 거래 확정 과정 메소드
  Future<void> handlePositiveButton(BuildContext context, Message message, String chatId) async {
    final chatRef = _firestore.collection('chats').doc(chatId).collection('messages').doc(message.id);

    bool? confirmed;
    switch (message.status) {
      case "ready":
        await chatRef.update({
          'status': 'deposit',
          'confirmationMessage.status': '입금 대기 중',
        });
        break;
      case "deposit":
        // '입금 확인 완료' 확인
        confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('입금을 확인하셨습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('예'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니오'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          await chatRef.update({
            'status': 'shipping',
            'confirmationMessage.status': '배송 확인 중',
          });
        }
        break;
      case "shipping":
        // '배송 확인 완료' 확인
        confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('배송을 확인하셨습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('예'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니오'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          await chatRef.update({
            'status': 'dealed',
            'confirmationMessage.status': '거래 완료',
          });
          await _updateUserListsOnDealCompletion(message, context);
        }
        break;
    }
    notifyListeners();
  }

  // 거래 취소 메서드
  Future<void> handleNegativeButton(Message message, String chatId, BuildContext context) async {
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('거래를 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('예'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('아니오'),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    final chatRef = _firestore.collection('chats').doc(chatId).collection('messages').doc(message.id);

    await chatRef.update({
      'status': 'canceled',
      'confirmationMessage.status': '거래가 취소되었습니다.',
    });
    
    notifyListeners();
  }

  // 각자 sellList, buyList에 추가하는 메소드
  Future<void> _updateUserListsOnDealCompletion(Message message, BuildContext context) async {
    final sellerId = message.uId;
    final buyerId = currentUserId == sellerId ? message.otherUserId : currentUserId;
    final postUid = message.confirmationMessage?['postUid'];

    if (postUid == null) {
      print('postUid가 null입니다.');
      return;
    }

    await _firestore.collection('users').doc(buyerId).update({
      'buyList': FieldValue.arrayUnion([postUid])
    });

    await _firestore.collection('posts').doc(postUid).update({
      'stockStatus': StockStatus.successSell.index
    });

    await Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
  }

  // 구매확정 버튼 관련 함수 분류 종료
  //////////////////////////////////////////////////////////////////////////////////////////////
  

  // Firestore 실시간 구독 함수
  void listenToMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      _messages = querySnapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
      fetchProfileImages(_messages.map((msg) => msg.uId).toList());
      notifyListeners();
    });
  }

  // 새 채팅방 생성 함수
  Future<void> _ensureChatRoomExists(String chatId, String userId, String otherUserId, String username, String currentUserProfileImage) async {
    DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    
    // 두 사용자 간의 채팅방이 이미 있는지 확인
    DocumentSnapshot chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      String otherUserName = await _getOtherUserNickname(otherUserId);
      String otherUserProfileImage = await _getOtherUserProfileImage(otherUserId);

      // 새 채팅방을 생성
      await chatRef.set({
        'participants': [userId, otherUserId],
        'lastActivityTime': Timestamp.now(),
        'lastMessage': '',
        'usernames': {
          userId: username,
          otherUserId: otherUserName,
        },
        'userProfileImages': {
          userId: currentUserProfileImage,
          otherUserId: otherUserProfileImage,
        }
      });
    }
  }

  // 메세지 보내기 함수
  Future<void> sendMessage(String chatId, String userId, String text, String otherUserId, String username, String currentUserProfileImage) async {
  await _ensureChatRoomExists(chatId, userId, otherUserId, username, currentUserProfileImage);
  DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

  // 메시지 전송
  await chatRef.collection('messages').add({
    'text': text,
    'uId': userId,
    'username': username,
    'createdAt': Timestamp.now(),
  });

  // 마지막 메시지 및 활동 시간 업데이트
  await chatRef.update({
    'lastActivityTime': Timestamp.now(),
    'lastMessage': text,
  });
}

  Future<void> sendImageMessage(String chatId, String userId, XFile imageFile, String username, String otherUserId, String currentUserProfileImage) async {
    try {
      await _ensureChatRoomExists(chatId, userId, otherUserId, username, currentUserProfileImage);

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('chat_images/$fileName');

      // 이미지 업로드 시작
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // 업로드된 이미지의 URL 가져오기
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // 이미지 URL을 Firestore에 메시지로 저장
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
      
      await chatRef.collection('messages').add({
        'text': '[Image]',
        'uId': userId,
        'imageUrl': imageUrl,
        'username': username,
        'createdAt': Timestamp.now(),
      });

      await chatRef.update({
        'lastActivityTime': Timestamp.now(),
        'lastMessage': '[Image]',
      });

      notifyListeners();
    } catch (e) {
      print('이미지 보내기 실패!!!!!!!!!!!!!!!!!!!!!! $e');
    }
  }

  // 프로필 이미지 firestore에서 가져오는 함수
  Future<void> fetchProfileImages(List<String> userIds) async {
    if (userIds.isEmpty) return;

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    final userProfiles = Map.fromEntries(
      usersSnapshot.docs.map((doc) => MapEntry(doc.id, doc.data()['userProfileImage'])),
    );

    for (var message in _messages) {
      message.profileImageUrl = userProfiles[message.uId];
    }
    notifyListeners();
  }

  // 상대방 닉네임 가져오기
  Future<String> _getOtherUserNickname(String uid) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      return userSnapshot['nickname'] ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  // 상대방 프로필 이미지 가져오기
  Future<String> _getOtherUserProfileImage(String uid) async {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
          return userSnapshot['userProfileImage'] ?? '';
      }
      return '';
  }
}
