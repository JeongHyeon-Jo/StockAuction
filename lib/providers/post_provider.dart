import 'dart:io';
import 'package:auction/models/bid_model.dart';
import 'package:auction/models/comment_model.dart';
import 'package:auction/models/post_model.dart';
import 'package:auction/models/result_model.dart';
import 'package:auction/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider with ChangeNotifier {
  bool isLoading = false;
  List<PostModel> sellingPosts = [];
  List<PostModel> biddingPosts = [];
  List<PostModel> soldPosts = [];
  List<PostModel> successBiddingPosts = [];
  List<PostModel> boughtPosts = [];
  bool hasError = false; // 오류 상태 추가
  List<PostModel> postList = [];
  PostModel? postModel;
  List<String> _likedPostTitles = [];
  Stream<DocumentSnapshot>? _postStream; //포스트 스트림으로 받아와서 실시간 업데이트
  String? _priceDifferenceAndPercentage;
  int? _postAuctionEndTime;


  String? get priceDifferenceAndPercentage => _priceDifferenceAndPercentage;
  int? get postAuctionEndTime => _postAuctionEndTime;
  List<String> get likedPostTitles => _likedPostTitles;

  List<BidModel> getSortedBids() {
    if (postModel == null) return [];
    return List.from(postModel!.bidList)
      ..sort((a, b) => b.bidTime.compareTo(a.bidTime));
  }

  List<BidModel> getSortedBidsExcludingAuthor() {
    if (postModel == null) return [];
    return postModel!.bidList
        .where((bid) => bid.bidUser.uid != postModel!.writeUser.uid)
        .toList()
      ..sort((a, b) => b.bidTime.compareTo(a.bidTime));
  }

  PostProvider() {
    loadLikedPostTitles();
  }

  Future<DataResult<List<PostModel>>> getAllPostList() async {
    isLoading = true;
    notifyListeners();

    try {
      isLoading = true;
      hasError = false; // 요청 시작 시 오류 상태 초기화
      notifyListeners();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createTime', descending: true)
          .get();

      postList = querySnapshot.docs
          .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
          .toList();

      return DataResult.success(postList, "success");
    } catch (e) {
      hasError = true; // 오류 발생 시 오류 상태 설정
      return DataResult.failure("Error fetching post list: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<List<String>> _uploadImages(List<String> postImageList) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    List<String> downloadPostImageList = [];

    for (String imagePath in postImageList) {
      if(imagePath.startsWith("http")){
        downloadPostImageList.add(imagePath);
        continue;
      }
      String fileName = DateTime.now().toIso8601String();
      Reference ref = storage.ref().child('post/$fileName');

      try {
        await ref.putFile(File(imagePath));
        String downloadURL = await ref.getDownloadURL();
        downloadPostImageList.add(downloadURL);
        print("Uploaded $fileName: $downloadURL");
      } catch (e) {
        print("Failed to upload $fileName: $e");
      }
    }

    return downloadPostImageList;
  }

  void listenToPost(String postUid) {
    isLoading = true;
    notifyListeners();

    _postStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(postUid)
        .snapshots();

    _postStream!.listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        postModel = PostModel.fromMap(snapshot.data() as Map<String, dynamic>);
        _sortComments(); // 댓글 정렬
        _calculateData();
        isLoading = false;
        notifyListeners();
      } else {
        // 문서가 존재하지 않는 경우 처리
        postModel = null;
        _priceDifferenceAndPercentage = null;
        _postAuctionEndTime = null;
        isLoading = false;
        notifyListeners();
      }
    }, onError: (error) {
      // 에러 처리
      print("Error: $error");
      isLoading = false;
      notifyListeners();
    });
  }

  Future<Result> addPostItem(PostModel post) async {
    isLoading = true;
    hasError = false; // 초기화
    notifyListeners();

    try {
      final downloadPostImageList = await _uploadImages(post.postImageList);
      post.postImageList = downloadPostImageList;

      post.postUid = FirebaseFirestore.instance.collection("posts").doc().id;
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(post.postUid)
          .set(post.toMap());

      return Result.success("게시물을 등록했습니다.");
    } catch (e) {
      hasError = true; // 오류 발생 시 오류 상태 설정
      return Result.failure("게시물 등록에 실패했습니다. 오류메시지 : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Result> modifyPostItem(PostModel modifidPost) async {
    isLoading = true;
    notifyListeners();

    try {
    final downloadImageList = await _uploadImages(modifidPost.postImageList);

    Map<String, dynamic> updatedFields = {
      'postTitle': modifidPost.postTitle,
      'postContent': modifidPost.postContent,
      'endTime': Timestamp.fromDate(modifidPost.endTime),
      'postImageList': downloadImageList
    };
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(modifidPost.postUid)
          .update(updatedFields);

      return Result.success("게시물을 수정했습니다.");
    } catch (e) {
      return Result.failure("게시물 수정에 실패했습니다. 오류메시지 : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Result> deletePostItem(String postUid) async {
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('posts').doc(postUid).delete();
      return Result.success("게시물을 삭제했습니다.");
    } catch (e) {
      return Result.failure("게시물 삭제에 실패했습니다. 오류메시지 : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Result> biddingPostItem(String postUid, String biddingUserUid, AuctionStatus auctionStatus, StockStatus stockStatus) async {
    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> data = {
        'auctionStatus': auctionStatus.index,
        'stockStatus': stockStatus.index,
        'successBiddingUser': biddingUserUid
      };

      await FirebaseFirestore.instance.collection('posts').doc(postUid).update(data);
      return Result.success("낙찰 완료되었습니다.");
    } catch (e) {
      return Result.failure("낙찰에 실패했습니다. 오류메시지 : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String postUid, UserModel currentUser) async {
    try {
      final postDoc = FirebaseFirestore.instance.collection('posts').doc(postUid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postDoc);
        if (!postSnapshot.exists) {
          throw Exception("Post does not exist!");
        }

        final post = PostModel.fromMap(postSnapshot.data()!);
        final isCurrentlyFavorited = post.isFavoritedBy(currentUser.uid);

        if (isCurrentlyFavorited) {
          post.removeFromFavorites(currentUser.uid);
          _likedPostTitles.remove(post.postUid);
        } else {
          post.addToFavorites(currentUser);
          _likedPostTitles.add(post.postUid);
        }

        transaction.update(postDoc, {'favoriteList': post.favoriteList});
      });

      // Update postList if necessary
      final index = postList.indexWhere((post) => post.postUid == postUid);
      if (index != -1) {
        postList[index].favoriteList = isPostLiked(postUid)
            ? [...postList[index].favoriteList, currentUser.toMap()]
            : postList[index].favoriteList.where((user) => user['uid'] != currentUser.uid).toList();
      }

      // Update postModel if it's the currently viewed post
      if (postModel?.postUid == postUid) {
        postModel!.favoriteList = isPostLiked(postUid)
            ? [...postModel!.favoriteList, currentUser.toMap()]
            : postModel!.favoriteList.where((user) => user['uid'] != currentUser.uid).toList();
      }

      await _saveLikedPostTitles();
      notifyListeners();
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }


  Future<Result> getPostItem(String postUid) async {
    isLoading = true;
    notifyListeners();

    try {
      final ref = await FirebaseFirestore.instance.collection('posts').doc(postUid).get();
      if (ref.exists) {
        postModel = PostModel.fromMap(ref.data() as Map<String, dynamic>);
        _sortComments(); // 댓글 정렬
        return DataResult<PostModel>.success(postModel!, "post 가져오기 성공");
      } else {
        return Result.failure("해당 게시물을 찾을 수 없습니다.");
      }
    } catch (e) {
      hasError = true;
      return Result.failure("데이터를 불러오지 못했습니다. 에러메시지 : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isPostFavorited(String postUid, String userId) async {
    try {
      final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postUid).get();
      if (postDoc.exists) {
        final post = PostModel.fromMap(postDoc.data()!);
        return post.isFavoritedBy(userId);
      }
      return false;
    } catch (e) {
      print("Error checking favorite status: $e");
      return false;
    }
  }

  Stream<List<PostModel>> getFavoritePosts(String userId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('favoriteList', arrayContains: {'uid': userId})
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _saveLikedPostTitles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('likedPostTitles', _likedPostTitles);
  }

  Future<void> loadLikedPostTitles() async {
    final prefs = await SharedPreferences.getInstance();
    _likedPostTitles = prefs.getStringList('likedPostTitles') ?? [];
    notifyListeners();
  }

  bool isPostLiked(String postUid) {
    final post = postList.firstWhere((post) => post.postUid == postUid, orElse: () => postModel!);
    return _likedPostTitles.contains(post.postUid);
  }

  Future<String?> getPostIdByTitle(String title) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('postUid', isEqualTo: title)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print("Error getting post ID by title: $e");
      return null;
    }
  }

  Future<String?> getFirstImageUrlByTitle(String title) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('postUid', isEqualTo: title)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final postData = querySnapshot.docs.first.data();
        final List<dynamic> imageList = postData['postImageList'];
        if (imageList.isNotEmpty) {
          return imageList[0] as String;
        }
      }
      return null;
    } catch (e) {
      print("Error getting first image URL by title: $e");
      return null;
    }
  }


  //입찰 하기
  Future<Result> addBidToPost(String postUid, BidModel bidData) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postUid).update({
        'bidList': FieldValue.arrayUnion([bidData.toMap()])
      });
      return Result.success("입찰에 성공했습니다.");
    } catch (e) {
      return Result.failure("입찰에 실패했습니다. 실패 코드 : $e");
    }
  }



  void _calculateData() {
    //입찰가 가격차이 , 퍼센트
    if ((postModel?.bidList.length ?? 0) > 1) {
      final firstPrice = postModel!.bidList.first.bidPrice;
      final lastPrice = postModel!.bidList.last.bidPrice;
      _priceDifferenceAndPercentage = calculatePriceDifferenceAndPercentage(
        firstPriceString: firstPrice,
        lastPriceString: lastPrice,
      );
    } else {
      _priceDifferenceAndPercentage = null;
    }

    //경매 남은 시간 계산
    _postAuctionEndTime = calculateEndTimeSeconds(postModel?.endTime);
  }


  int calculateEndTimeSeconds(DateTime? endTime) {
    //null 일 경우 0 출력
    if(endTime == null){
      return 0;
    }

    final now = DateTime.now();
    final difference = endTime.difference(now);

    // difference.inSeconds가 음수일 경우 (즉, 종료 시간이 이미 지났을 경우) 0을 반환
    return difference.inSeconds > 0 ? difference.inSeconds : 0;
  }

  //마지막 입찰가 - 첫 입찰가
  String calculatePriceDifferenceAndPercentage(
      {required String firstPriceString, required String lastPriceString}) {
    // 숫자 형태로 변환 (숫자와 쉼표 제거)
    int lastPrice =
    int.parse(lastPriceString.replaceAll(',', '').replaceAll('원', ''));
    int firstPrice =
    int.parse(firstPriceString.replaceAll(',', '').replaceAll('원', ''));

    // 가격 차이 계산
    int difference = (lastPrice - firstPrice).abs();

    // 오른 가격 비율 계산
    double percentage = ((difference / firstPrice) * 100);

    // 쉼표를 포함한 금액 형태로 변환하는 함수
    String formatWithCommas(int price) {
      return price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
      );
    }

    // 결과를 문자열로 반환
    return '${formatWithCommas(difference)}원 (+${percentage.toStringAsFixed(1)}%)';
  }

  Future<PostModel?> getPostByUid(String postUid) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('posts').doc(postUid).get();
      if (docSnapshot.exists) {
        return PostModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error getting post by UID: $e");
      return null;
    }
  }

  List<PostModel> getMyBidPosts(String userId) {
    return postList.where((post) => post.bidList.any((bid) => bid.bidUser.uid == userId)).toList();
  }

  Future<Result> addCommentToPost(String postUid, CommentModel comment) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postUid);

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);
        if (!snapshot.exists) {
          return Result.failure("게시물을 찾을 수 없습니다.");
        }

        final post = PostModel.fromMap(snapshot.data()!);

        // 중복 댓글 확인
        if (post.commentList.any((c) => c.uid == comment.uid && c.commentTime == comment.commentTime)) {
          return Result.failure("이미 추가된 댓글입니다.");
        }

        post.commentList.add(comment);
        post.commentList.sort((a, b) => b.commentTime.compareTo(a.commentTime));

        transaction.update(postRef, {'commentList': post.commentList.map((c) => c.toMap()).toList()});

        // Update local postModel if it's the current post
        if (postModel?.postUid == postUid) {
          postModel = post;
          notifyListeners();
        }

        return Result.success("댓글이 추가되었습니다.");
      });
    } catch (e) {
      return Result.failure("댓글 추가에 실패했습니다. 오류: $e");
    }
  }

  void _sortComments() {
    if (postModel != null && postModel!.commentList.isNotEmpty) {
      postModel!.commentList.sort((a, b) => b.commentTime.compareTo(a.commentTime));
    }
  }

  Future<Result> editComment(String postUid, CommentModel updatedComment) async {
    try {
      final postDoc = FirebaseFirestore.instance.collection('posts').doc(postUid);
      final postSnapshot = await postDoc.get();
      if (!postSnapshot.exists) {
        return Result.failure("게시물을 찾을 수 없습니다.");
      }

      final post = PostModel.fromMap(postSnapshot.data()!);
      final commentIndex = post.commentList.indexWhere((c) => c.uid == updatedComment.uid);
      if (commentIndex == -1) {
        return Result.failure("댓글을 찾을 수 없습니다.");
      }

      post.commentList[commentIndex] = updatedComment;

      await postDoc.update({'commentList': post.commentList.map((c) => c.toMap()).toList()});

      // Update local postModel if it's the current post
      if (postModel?.postUid == postUid) {
        postModel!.commentList[commentIndex] = updatedComment;
        notifyListeners();
      }

      return Result.success("댓글이 수정되었습니다.");
    } catch (e) {
      return Result.failure("댓글 수정에 실패했습니다. 오류: $e");
    }
  }

  Future<Result> deleteComment(String postUid, String commentId) async {
    try {
      final postDoc = FirebaseFirestore.instance.collection('posts').doc(postUid);

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postDoc);
        if (!snapshot.exists) {
          return Result.failure("게시물을 찾을 수 없습니다.");
        }

        final post = PostModel.fromMap(snapshot.data()!);
        final initialCommentCount = post.commentList.length;
        post.commentList.removeWhere((c) => c.id == commentId);

        if (post.commentList.length == initialCommentCount) {
          return Result.failure("해당 댓글을 찾을 수 없습니다.");
        }

        transaction.update(postDoc, {'commentList': post.commentList.map((c) => c.toMap()).toList()});

        // Update local postModel if it's the current post
        if (postModel?.postUid == postUid) {
          postModel = post;
          notifyListeners();
        }

        return Result.success("댓글이 삭제되었습니다.");
      });
    } catch (e) {
      return Result.failure("댓글 삭제에 실패했습니다. 오류: $e");
    }
  }
  /////////////////////////////////////////////////////////////////////////////////
  /// sold_screen, bought_screen 관련 메서드

  // PostUid 리스트 받으면 안에 있는 애들 정보 갖고 오기
  Future<void> fetchPostsByUids(List<String> postUids) async {
    isLoading = true;
    notifyListeners();

    postList = [];
    try {
      for (int i = 0; i < postUids.length; i += 10) {
        final sublist = postUids.sublist(i, i + 10 > postUids.length ? postUids.length : i + 10);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('postUid', whereIn: sublist)
            .where('auctionStatus', isEqualTo: AuctionStatus.successBidding.index)
            .where('stockStatus', isEqualTo: StockStatus.successSell.index)
            .get();

        final fetchedPosts = querySnapshot.docs
            .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
            .toList();

        postList.addAll(fetchedPosts);
      }
    } catch (e) {
      print("PostUid 리스트 불러오기 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBoughtPosts(List<String> postUids) async {
    isLoading = true;
    notifyListeners();
    boughtPosts = [];

    try {
      for (int i = 0; i < postUids.length; i += 10) {
        final sublist = postUids.sublist(i, i + 10 > postUids.length ? postUids.length : i + 10);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('postUid', whereIn: sublist)
            .where('auctionStatus', isEqualTo: AuctionStatus.successBidding.index)
            .where('stockStatus', isEqualTo: StockStatus.successSell.index)
            .get();
        print('패치 ${querySnapshot.size} documents for sublist: $sublist');

        final fetchedPosts = querySnapshot.docs
            .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
            .toList();

        boughtPosts.addAll(fetchedPosts.where((newPost) =>
          !boughtPosts.any((existingPost) => existingPost.postUid == newPost.postUid)));
      }
    } catch (e) {
      print("구매한 포스트 불러오기 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // selling posts 불러오기 successBidding, readySell 상태여야 함
  Future<void> fetchUserSellingPosts(String userId) async {
    isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('writeUser.uid', isEqualTo: userId)
          .where('auctionStatus', isEqualTo: AuctionStatus.successBidding.index)
          .where('stockStatus', isEqualTo: StockStatus.readySell.index)
          .get();

      sellingPosts = querySnapshot.docs
          .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("판매중인 포스트 불러오기 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 경매중인 posts 불러오기 bidding, readySell 상태여야 함
  Future<void> fetchUserBiddingPosts(String userId) async {
    isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('writeUser.uid', isEqualTo: userId)
          .where('auctionStatus', isEqualTo: AuctionStatus.bidding.index)
          .where('stockStatus', isEqualTo: StockStatus.bidding.index)
          .get();

      biddingPosts = querySnapshot.docs
          .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("판매중인 포스트 불러오기 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // sold posts 불러오기 successBidding, successSell 상태여야 함
  Future<void> fetchUserSoldPosts(List<String> postUids) async {
    isLoading = true;
    notifyListeners();
    soldPosts = [];

    try {
      for (int i = 0; i < postUids.length; i += 10) {
        final sublist = postUids.sublist(i, i + 10 > postUids.length ? postUids.length : i + 10);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('postUid', whereIn: sublist)
            .where('auctionStatus', isEqualTo: AuctionStatus.successBidding.index)
            .where('stockStatus', isEqualTo: StockStatus.successSell.index)
            .get();

        final fetchedPosts = querySnapshot.docs
            .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
            .toList();

        soldPosts.addAll(fetchedPosts);
      }
    } catch (e) {
      print("판매된 포스트 불러오기 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSuccessBiddingPosts() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('auctionStatus', isEqualTo: AuctionStatus.successBidding.index)
          .get();

      successBiddingPosts = querySnapshot.docs
          .map((snapshot) => PostModel.fromMap(snapshot.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("낙찰된 포스트 불러오기 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// sold_screen, bought_screen 관련 메서드 종료
  ////////////////////////////////////////////////////////////////////////////////////
}