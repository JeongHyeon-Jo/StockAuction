import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/providers/user_provider.dart';

class OtherSoldScreen extends StatefulWidget {
  final String uId;

  const OtherSoldScreen({Key? key, required this.uId}) : super(key: key);

  @override
  _OtherSoldScreenState createState() => _OtherSoldScreenState();
}

class _OtherSoldScreenState extends State<OtherSoldScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUser(widget.uId).then((_) {
        final sellList = Provider.of<UserProvider>(context, listen: false).user?.sellList ?? [];
        if (sellList.isNotEmpty) {
          Provider.of<PostProvider>(context, listen: false).fetchUserSoldPosts(sellList);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('판매완료 상품 목록'),
      ),
      body: postProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: postProvider.soldPosts.length,
              itemBuilder: (context, index) {
                final post = postProvider.soldPosts[index];
                return ListTile(
                  leading: post.postImageList.isNotEmpty
                      ? Image.network(post.postImageList[0], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(post.postTitle.length > 15 
                      ? '${post.postTitle.substring(0, 15)}...' 
                      : post.postTitle),
                  subtitle: Text(post.postContent.length > 30
                      ? '${post.postContent.substring(0, 30)}...'
                      : post.postContent),
                );
              },
            ),
    );
  }
}
