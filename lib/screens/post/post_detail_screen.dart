import 'dart:math';

import 'package:auction/models/bid_model.dart';
import 'package:auction/models/post_model.dart';
import 'package:auction/utils/function_method.dart';
import 'package:auction/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:auction/config/color.dart';
import 'package:auction/models/comment_model.dart';
import 'package:auction/models/user_model.dart';
import 'package:auction/providers/auction_timer_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/screens/post/widgets/comment_widget.dart';
import 'package:auction/screens/post/widgets/favorite_button_widget.dart';
import 'package:auction/screens/post/widgets/timer_text_widget.dart';
import 'package:auction/utils/SharedPrefsUtil.dart';
import 'package:auction/utils/custom_alert_dialog.dart';
import 'package:auction/providers/text_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postUid;


  const PostDetailScreen({Key? key, required this.postUid, req}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController _priceTextController;
  UserModel? loginedUser;
  bool isLoading = true;
  bool _isPriceFocused = false;
  final _priceFocusNode = FocusNode();
  bool _showAllComments = false;
  static const int _initialCommentCount = 5;
  static const int _incrementalCommentCount = 5;
  int _displayedCommentCount = _initialCommentCount;


  @override
  void initState() {
    super.initState();
    _priceTextController = TextEditingController();
    _priceFocusNode.addListener(_onFocusChange);

    _loadData();
  }

  void _onFocusChange() {
    setState(() {
      _isPriceFocused = _priceFocusNode.hasFocus;
    });
  }

  Future<void> _loadData() async {
    await _setUserData();
    await _fetchPostItem(widget.postUid);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _setUserData() async {
    final stringUserData = await SharedPrefsUtil.getUserData();
    if (stringUserData != null) {
      setState(() {
        loginedUser = UserModel.fromMap(stringUserData);
      });
    }
  }

  // Future<void> _loadFavoriteStatus() async {
  //   final postProvider = Provider.of<PostProvider>(context, listen: false);
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   final currentUser = await authProvider.getCurrentUser();
  //   if (currentUser != null) {
  //     bool favorited = await postProvider.isPostFavorited(widget.postUid, currentUser.uid);
  //     setState(() {
  //       isFavorited = favorited;
  //     });
  //   }
  // }

  Future<void> _fetchPostItem(String postUid) async {
    /*final postProvider = Provider.of<PostProvider>(context, listen: false);
    final result = await postProvider.getPostItem(postUid);

    if (!result.isSuccess || postProvider.postModel == null) {
      showCustomAlertDialog(
        context: context,
        title: "알림",
        message: result.message ?? "데이터를 가져오지 못했습니다.",
      );
    }*/
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.listenToPost(widget.postUid);

    // showCustomAlertDialog(context: context, title: "알림", message: "경매 데이터를 불러오지 못했습니다.",onClick: () => context.go("/main/post"));
  }

  void _toggleFavorite(PostProvider postProvider, UserModel currentUser) async {
    await postProvider.toggleFavorite(widget.postUid, currentUser);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (postProvider.postModel == null) {
          return const Scaffold(
            body: Center(child: Text("경매 데이터를 불러오지 못했습니다.")),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(postProvider, authProvider),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSwiper(postProvider),
                      _buildPostContent(postProvider),
                      _buildCommentSection(postProvider),
                    ],
                  ),
                ),
              ),
              _buildBottomSection(postProvider),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(PostProvider postProvider, AuthProvider authProvider) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: const Text("게시물", style: TextStyle(fontSize: 20.0)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (loginedUser?.uid == postProvider.postModel?.writeUser.uid)
          IconButton(
            icon: const Icon(Icons.more_vert_outlined),
            onPressed: () => _showOptionsBottomSheet(context, postProvider, authProvider),
          ),
      ],
    );
  }

  Widget _buildImageSwiper(PostProvider postProvider) {
    return SizedBox(
      height: 300,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return postProvider.postModel?.postImageList[index] != null
              ? Image.network(
                  postProvider.postModel!.postImageList[index],
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Text(
                    "사진을 불러오지 못했습니다",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
        },
        itemCount: postProvider.postModel?.postImageList.length ?? 0,
        pagination: postProvider.postModel!.postImageList.length >= 2
            ? const SwiperPagination()
            : null,
      ),
    );
  }

  Widget _buildPostContent(PostProvider postProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(postProvider),
          const Divider(thickness: 1, color: AppsColor.lightGray),
          _buildPostTitle(postProvider),
          const SizedBox(height: 15),
          Text(
            postProvider.postModel?.postContent ?? "Unknown Content",
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 30.0),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }

  void _navigateToUserProfile(String userId) {
    context.push('/other/profile/$userId');
  }

  Widget _buildUserInfo(PostProvider postProvider) {
    final user = postProvider.postModel?.writeUser;
    final latestBidder = postProvider.postModel?.bidList.isNotEmpty == true
        ? postProvider.postModel!.bidList.last.bidUser
        : null;
    final auctionStatus = postProvider.postModel?.auctionStatus;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildUserInfoItem(user?.uid, user?.userProfileImage, user?.nickname ?? "Unknown User", auctionStatus: auctionStatus),
        if (latestBidder != null && latestBidder.uid != user?.uid)
          _buildUserInfoItem(latestBidder.uid, latestBidder.userProfileImage, latestBidder.nickname, isBidder: true, auctionStatus: auctionStatus),
      ],
    );
  }

  Widget _buildUserInfoItem(String? uid, String? imageUrl, String name, {bool isBidder = false, AuctionStatus? auctionStatus}) {
    return GestureDetector(
      onTap: () => _navigateToUserProfile(uid ?? ''),
      child: Row(
        children: [
          if (!isBidder) ...[
            ClipOval(
              child: imageUrl == null || imageUrl.isEmpty
                  ? Image.asset(
                "lib/assets/image/defaultUserProfile.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (isBidder) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  auctionStatus != AuctionStatus.bidding
                      ? "낙찰자"
                      : "현재 입찰자",
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            ClipOval(
              child: imageUrl == null || imageUrl.isEmpty
                  ? Image.asset(
                "lib/assets/image/defaultUserProfile.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  //포스트 상세화면 제목 내용
  Widget _buildPostTitle(PostProvider postProvider) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentUser = authProvider.currentUserModel;
        final postTitle = postProvider.postModel?.postTitle ?? "Unknown Title";
        final isLiked = postProvider.isPostLiked(widget.postUid);

        return Row(
          children: [
            Expanded(
              child: Text(
                postTitle,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            if (currentUser != null)
              IconButton(
                icon: Icon(
                  isLiked ? Icons.bookmark : Icons.bookmark_border,
                  color: isLiked ? AppsColor.pastelGreen : null,
                ),
                onPressed: () => postProvider.toggleFavorite(widget.postUid, currentUser),
              ),
          ],
        );
      },
    );
  }
  //댓글 창
  Widget _buildCommentSection(PostProvider postProvider) {
    final comments = postProvider.postModel?.commentList ?? [];
    final commentCount = comments.length;
    final displayedComments = comments.take(_displayedCommentCount).toList();
    final authorUid = postProvider.postModel?.writeUser.uid; // 게시물 작성자의 UID

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '댓글 $commentCount',
                style: const TextStyle(fontSize: 14),
              ),
              GestureDetector(
                onTap: () => _showCommentBottomSheet(context),
                child: const Text(
                  '댓글 쓰기',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        comments.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Text(
              "아직 작성된 댓글이 없어요.\n제일 먼저 댓글을 작성해 보세요.",
              textAlign: TextAlign.center,
            ),
          ),
        )
            : Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedComments.length,
              itemBuilder: (context, index) {
                return CommentWidget(
                  commentModel: displayedComments[index],
                  postUid: widget.postUid,
                  isAuthor: displayedComments[index].uid == authorUid, // 작성자 여부 전달
                );
              },
            ),
            if (_displayedCommentCount < commentCount)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _displayedCommentCount = min(
                          _displayedCommentCount + _incrementalCommentCount,
                          commentCount
                      );
                    });
                  },
                  child: Text('이전 댓글 ${min(_incrementalCommentCount, commentCount - _displayedCommentCount)}개 더보기'),
                ),
              ),
          ],
        ),
      ],
    );
  }
  //포스트 상세 화면 바텀 바
  Widget _buildBottomSection(PostProvider postProvider) {
    return ChangeNotifierProvider(
      create: (context) => AuctionTimerProvider(postProvider.postAuctionEndTime ?? 0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceAndTimer(),
              const SizedBox(height: 16),
              _buildBidInputAndButton(postProvider),
            ],
          ),
        ),
      ),
    );
  }
  //입찰 정보
  Widget _buildPriceAndTimer() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAuctionStatusText(postProvider.postModel!.auctionStatus),
                TimerTextWidget(postProvider: postProvider),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      postProvider.postModel!.bidList.last.bidPrice,
                      style: postProvider.postModel!.auctionStatus != AuctionStatus.bidding ?
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)
                          :const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
                    ),
                  ),
                ),
                postProvider.priceDifferenceAndPercentage != null
                    ? Flexible(
                        flex: 1, // 오른쪽 부분에도 1의 가중치 부여
                        child: GestureDetector(
                          onTap: () => context.push("/post/bidlist"),
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.arrow_drop_up,
                                      color: Colors.redAccent),
                                  Text(
                                    postProvider.priceDifferenceAndPercentage ?? "",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.redAccent),
                                  ),
                                ],
                              )),
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ],
        );
      },
    );
  }
  //입찰 가격 버튼
  Widget _buildBidInputAndButton(PostProvider postProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextField(
            controller: _priceTextController,
            keyboardType: TextInputType.number,
            autofocus: false,
            focusNode: _priceFocusNode,
            onChanged: (value) {
              final formattedValue = formatPrice(value);
              _priceTextController.value = TextEditingValue(
                text: formattedValue,
                selection:
                    TextSelection.collapsed(offset: formattedValue.length),
              );
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '가격을 입력해주세요',
            ),
          ),
        ),
        const SizedBox(width: 20),
        Consumer<AuctionTimerProvider>(
          builder: (context, auctionTimerProvider, child) {
            if (loginedUser!.uid == postProvider.postModel!.writeUser.uid) {
              return ElevatedButton(
                //내가 판매자 인 경우
                onPressed: auctionTimerProvider.remainingTime != 0 &&
                        postProvider.postModel!.auctionStatus ==
                            AuctionStatus.bidding //입찰중 상태면서 남은시간 0 아닐경우
                    ? () {
                        // todo successbidStart(postProvider); -> 마지막 입찰자를 낙찰자로 선정, state를 selling ->  bidSuccess로 -> soldOut
                        biddingSuccess(postProvider);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: auctionTimerProvider.remainingTime != 0
                      ? AppsColor.pastelGreen
                      : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child:
                    const Text('낙찰하기', style: TextStyle(color: Colors.white)),
              );
            } else {
              return ElevatedButton(
                // 내가 입찰자 인 경우
                onPressed: auctionTimerProvider.remainingTime != 0 &&
                        postProvider.postModel!.auctionStatus ==
                            AuctionStatus.bidding //입찰중 상태면서 남은시간 0 아닐경우
                    ? () {
                        bidStart(postProvider);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: auctionTimerProvider.remainingTime != 0
                      ? AppsColor.pastelGreen
                      : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child:
                    const Text('입찰하기', style: TextStyle(color: Colors.white)),
              );
            }
          },
        ),
      ],
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: const Text('댓글 작성'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          if (commentController.text.isNotEmpty) {
                            final postProvider = Provider.of<PostProvider>(context, listen: false);
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final currentUser = authProvider.currentUserModel;
                            if (currentUser != null) {
                              final newComment = CommentModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 id 생성
                                uid: currentUser.uid,
                                userProfileImage: currentUser.userProfileImage ?? '',
                                userName: currentUser.nickname,
                                comment: commentController.text,
                                commentTime: DateTime.now(),
                              );
                              final result = await postProvider.addCommentToPost(widget.postUid, newComment);
                              if (result.isSuccess) {
                                Navigator.pop(context);
                                setState(() {
                                  _displayedCommentCount = _initialCommentCount;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result.message ?? '댓글 작성에 실패했습니다.')),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('작성'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context,
      PostProvider postProvider,
      AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('수정'),
                onTap: () {
                  context.pop();
                  context.push("/post/modify");
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('삭제'),
                onTap: () async {
                  final postUid = postProvider.postModel?.postUid ?? "";
                  final deletePostResult =
                      await postProvider.deletePostItem(postUid);
                  final deletePostInSellList = await authProvider
                      .deletePostInSellList(loginedUser!.uid, postUid);

                  if (deletePostResult.isSuccess &&
                      deletePostInSellList.isSuccess) {
                    showCustomAlertDialog(
                        context: context,
                        title: "알림",
                        message: deletePostResult.message ?? "게시물이 삭제되었습니다.",
                        onPositiveClick: () => context.go("/main/post"));
                  } else {
                    showCustomAlertDialog(
                        context: context,
                        title: "알림",
                        message: deletePostResult.message ?? "삭제에 실패했습니다.");
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('취소'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //입찰 로직
  void bidStart(PostProvider postProvider) {
    if (_priceTextController.text.isEmpty) {
      showCustomAlertDialog(
          context: context, title: "알림", message: "가격을 입력해주세요.");
      return;
    } else if (parseIntPrice(_priceTextController.text) -
            parseIntPrice(postProvider.postModel!.bidList.last.bidPrice) <=
        0) {
      showCustomAlertDialog(
          context: context, title: "알림", message: "현재 입찰가보다 높은 금액을 입력해주세요.");
      return;
    }

    showCustomAlertDialog(context: context, title: "알림", message: "입찰 하시겠습니까?",
        positiveButtonText: "예" ,
        onPositiveClick: () async {
          context.pop();
          final bidData = BidModel(
              bidUser: loginedUser!,
              bidTime: DateTime.now(), // DateTime 객체로 직접 전달
              bidPrice: "${_priceTextController.text}원"
          );


        final result = await postProvider.addBidToPost(
            postProvider.postModel!.postUid, bidData);

        if (result.isSuccess) {
          setState(() {
            _priceTextController.clear(); // 텍스트 지우기
            _priceFocusNode.unfocus();
          });

          //입찰 push 보내기
          sendNotification(title: "입찰 알림",
              body: "${postProvider.postModel!.bidList.last.bidUser.nickname}님이 입찰하셨습니다. 확인해보세요!",
              pushToken: postProvider.postModel!.writeUser.pushToken ?? "",
          screen: "/post/detail?${postProvider.postModel!.postUid}");

          showCustomAlertDialog(
              context: context,
              title: "알림",
              message: result.message ?? "입찰 되었습니다.",
              positiveButtonText: "확인");
        } else {
          showCustomAlertDialog(
              context: context,
              title: "알림",
              message: result.message ?? "입찰에 실패했습니다.");
        }
      },
      negativeButtonText: "아니요",
      onNegativeClick: null,
    );
  }

  Future<void> biddingSuccess(PostProvider postProvider) async {
    final result = await postProvider.biddingPostItem(
        postProvider.postModel!.postUid,
        loginedUser!.uid,
        AuctionStatus.successBidding,
        StockStatus.readySell);
    if (result.isSuccess) {

      //낙찰 push 알림
      sendNotification(title: "낙찰 알림",
          body: "${postProvider.postModel!.postTitle} 상품이 낙찰되었습니다. 확인해보세요!",
          pushToken: postProvider.postModel!.bidList.last.bidUser.pushToken ?? "", screen: "/post/detail?${postProvider.postModel!.postUid}");

      showCustomAlertDialog(
          context: context,
          title: "알림",
          message: result.message ?? "낙찰 되었습니다.");
    } else {
      showCustomAlertDialog(
          context: context,
          title: "알림",
          message: result.message ?? "낙찰에 실패했습니다.");
    }
  }

  @override
  void dispose() {
    _priceTextController.dispose();
    _priceFocusNode.removeListener(_onFocusChange);
    _priceFocusNode.dispose();
    super.dispose();
  }

  _buildAuctionStatusText(AuctionStatus auctionStatus) {
    switch (auctionStatus) {
      case AuctionStatus.bidding:
        return const Text('현재 입찰가', style: TextStyle(fontSize: 16));
      case AuctionStatus.successBidding:
        return const Text('낙찰가', style: TextStyle(fontSize: 16));
      case AuctionStatus.failBidding:
        return const Text('유찰된 상품', style: TextStyle(fontSize: 16));
    }
  }

}
