import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auction/models/post_model.dart';

class MyBidsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나의 입찰 목록'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final currentUser = authProvider.currentUserModel;
          if (currentUser == null) {
            return Center(child: Text('로그인이 필요합니다.'));
          }

          return Consumer<PostProvider>(
            builder: (context, postProvider, _) {
              final myBidPosts = postProvider.getMyBidPosts(currentUser.uid);

              if (myBidPosts.isEmpty) {
                return Center(child: Text('입찰한 게시물이 없습니다.'));
              }

              return ListView.builder(
                itemCount: myBidPosts.length,
                itemBuilder: (context, index) {
                  final post = myBidPosts[index];
                  final latestBid = post.bidList.isNotEmpty ? post.bidList.last.bidPrice : '입찰 없음';

                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      child: post.postImageList.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post.postImageList[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      )
                          : Icon(Icons.image_not_supported),
                    ),
                    title: Text(post.postTitle),
                    subtitle: Text('현재 입찰가: $latestBid'),
                    trailing: Icon(Icons.gavel),
                    onTap: () {
                      context.push('/post/detail', extra: post.postUid);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }


}