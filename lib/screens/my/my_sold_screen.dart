import 'package:auction/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';

class MySoldScreen extends StatefulWidget {
  const MySoldScreen({Key? key}) : super(key: key);

  @override
  _MySoldScreenState createState() => _MySoldScreenState();
}

class _MySoldScreenState extends State<MySoldScreen> {
  bool _isSelling = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPostsBasedOnStatus();
    });
  }

  // 판매중 판매완료 Post 갱신하기
  void fetchPostsBasedOnStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (_isSelling) {
      postProvider.fetchUserSellingPosts(authProvider.currentUserModel?.uid ?? '');
    } else {
      final sellList = authProvider.currentUserModel?.sellList ?? [];
      if (sellList.isNotEmpty) {
        final test = postProvider.fetchUserSoldPosts(sellList);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 판매 내역'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isSelling = true;
                    });
                    fetchPostsBasedOnStatus();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: themeProvider.isDarkTheme ?
                    _isSelling ? Colors.grey : AppsColor.darkGray :
                    _isSelling ? Colors.grey : Colors.white,
                  ),
                  child: const Text('판매중'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isSelling = false;
                    });
                    fetchPostsBasedOnStatus();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: themeProvider.isDarkTheme ?
                    _isSelling ? AppsColor.darkGray : Colors.grey :
                    _isSelling ? Colors.white : Colors.grey,
                  ),
                  child: const Text('판매완료'),
                ),
              ),
            ],
          ),
          Expanded(
            child: postProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _isSelling ? postProvider.sellingPosts.length : postProvider.soldPosts.length,
                    itemBuilder: (context, index) {
                      final post = _isSelling ? postProvider.sellingPosts[index] : postProvider.soldPosts[index];
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
          ),
        ],
      ),
    );
  }
}