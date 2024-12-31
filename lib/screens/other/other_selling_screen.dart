import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/post_provider.dart';

class OtherSellingScreen extends StatefulWidget {
  final String uId;

  const OtherSellingScreen({Key? key, required this.uId}) : super(key: key);

  @override
  _OtherSellingScreenState createState() => _OtherSellingScreenState();
}

class _OtherSellingScreenState extends State<OtherSellingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchUserSellingPosts(widget.uId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('판매중인 상품 목록'),
      ),
      body: postProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: postProvider.sellingPosts.length,
              itemBuilder: (context, index) {
                final post = postProvider.sellingPosts[index];
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
