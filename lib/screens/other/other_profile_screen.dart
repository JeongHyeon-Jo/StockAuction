import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/user_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auction/screens/other/widgets/post_list_widget.dart';

class OtherProfileScreen extends StatefulWidget {
  final String uId;

  const OtherProfileScreen({super.key, required this.uId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUser(widget.uId);
      Provider.of<PostProvider>(context, listen: false).fetchUserSellingPosts(widget.uId);
      Provider.of<PostProvider>(context, listen: false).fetchUserBiddingPosts(widget.uId);
      Provider.of<UserProvider>(context, listen: false).fetchUser(widget.uId).then((_) {
        final sellList = Provider.of<UserProvider>(context, listen: false).user?.sellList ?? [];
        Provider.of<PostProvider>(context, listen: false).fetchUserSoldPosts(sellList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final isCurrentUser = authProvider.currentUser?.uid == widget.uId;

    return Scaffold(
      appBar: AppBar(
        title: Text(userProvider.user != null 
          ? '${userProvider.user!.nickname}님의 프로필' 
          : '프로필 로딩 중'),
      ),
      body: SingleChildScrollView(
        child:
          Center(
            child: userProvider.fetchStatus == FetchStatus.loading
              ? CircularProgressIndicator()
              : userProvider.fetchStatus == FetchStatus.failed
                ? Text(
                    "사용자를 찾을 수 없습니다.",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 해당 유저의 프로필 이미지 표시
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: userProvider.user!.userProfileImage != null && userProvider.user!.userProfileImage!.isNotEmpty
                            ? CachedNetworkImageProvider(userProvider.user!.userProfileImage!)
                            : AssetImage("lib/assets/image/defaultUserProfile.png") as ImageProvider,
                      ),
                      SizedBox(height: 16),
                      // 해당 유저 닉네임 표시
                      Text(
                        userProvider.user!.nickname,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // 본인이 아닌 다른 사람 프로필 눌렀을때만 뜨는 아이콘 버튼 ↓↓↓
                      if (!isCurrentUser)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chat),
                              iconSize: 30.0,
                              color: Colors.blue,
                              onPressed: () {
                                // 채팅 화면으로 이동
                                final ids = [widget.uId, authProvider.currentUser?.uid];
                                ids.sort();
                                final chatId = ids.join('_');
                                GoRouter.of(context).push('/chat/$chatId');
                              },
                            ),
                            Text('1:1 대화',
                            style: TextStyle(
                              fontSize: 14,
                            ),),
                          ],
                        ),
                      Divider(
                        indent: 16,
                        endIndent: 16,
                        thickness: 0.5,
                      ),
          
                      Text("경매중인 상품", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      PostListWidget(posts: postProvider.biddingPosts, route: '/post/detail'),
          
                      Divider(
                        indent: 16,
                        endIndent: 16,
                        thickness: 0.5,
                      ),
          
                      Text("판매중인 상품", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      PostListWidget(posts: postProvider.sellingPosts, route: '/other/selling/${widget.uId}'),
          
                      Divider(
                        indent: 16,
                        endIndent: 16,
                        thickness: 0.5,
                      ),
          
                      Text("판매완료 상품", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      PostListWidget(posts: postProvider.soldPosts, route: '/other/sold/${widget.uId}'),
                    ],
                  ),
          ),
      ),
    );
  }
}
