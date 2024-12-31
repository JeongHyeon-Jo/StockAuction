import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:go_router/go_router.dart';

class MyBoughtScreen extends StatefulWidget {
  const MyBoughtScreen({Key? key}) : super(key: key);

  @override
  _MyBoughtScreenState createState() => _MyBoughtScreenState();
}

class _MyBoughtScreenState extends State<MyBoughtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBoughtPosts();
    });
  }

  // 구매한 Post 목록을 불러오기
  void fetchBoughtPosts() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final buyList = authProvider.currentUserModel?.buyList ?? [];
    if (buyList.isNotEmpty) {
      postProvider.fetchBoughtPosts(buyList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 구매 내역'),
      ),
      body: postProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: postProvider.boughtPosts.length,
              itemBuilder: (context, index) {
                final post = postProvider.boughtPosts[index];
                return ListTile(
                  leading: post.postImageList.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            post.postImageList[0],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image),
                  title: Text(post.postTitle.length > 15 
                      ? '${post.postTitle.substring(0, 15)}...' 
                      : post.postTitle),
                  subtitle: Text(post.postContent.length > 30
                      ? '${post.postContent.substring(0, 30)}...'
                      : post.postContent),
                  onTap: () {
                    context.push('/post/detail/${post.postUid}');
                  },
                );
              },
            ),
    );
  }
}
