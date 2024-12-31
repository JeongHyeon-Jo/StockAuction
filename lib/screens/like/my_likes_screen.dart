import 'package:auction/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auction/models/post_model.dart';

class MyLikesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentUser = authProvider.currentUserModel;
        if (currentUser == null) {
          return Center(child: Text('로그인이 필요합니다.'));
        }

        return Consumer<PostProvider>(
          builder: (context, postProvider, _) {
            final likedPostUids = postProvider.likedPostTitles; // 실제로는 postUids를 저장하고 있음

            if (likedPostUids.isEmpty) {
              return Center(child: Text('좋아요한 게시물이 없습니다.'));
            }

            return ListView.builder(
              itemCount: likedPostUids.length,
              itemBuilder: (context, index) {
                return FutureBuilder<PostModel?>(
                  future: postProvider.getPostByUid(likedPostUids[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('로딩 중...'),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return ListTile(
                        leading: Icon(Icons.error),
                        title: Text('게시물을 불러올 수 없습니다.'),
                      );
                    }

                    final post = snapshot.data!;
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
                      trailing: Icon(Icons.bookmark, color: AppsColor.pastelGreen),
                      onTap: () {
                        context.push('/post/detail', extra: post.postUid);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}