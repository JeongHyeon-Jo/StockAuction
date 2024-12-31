import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auction/models/post_model.dart';

class PostListWidget extends StatelessWidget {
  final List<PostModel> posts;
  final String route;

  const PostListWidget({Key? key, required this.posts, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return posts.isEmpty
        ? Text('상품이 없습니다.')
        : Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    if(route == '/post/detail'){
                      GoRouter.of(context).push('$route/${post.postUid}');
                    } else {
                      GoRouter.of(context).push(route);
                    }
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        post.postImageList.isNotEmpty
                            ? Image.network(post.postImageList[0], width: 80, height: 80, fit: BoxFit.cover)
                            : Icon(Icons.image, size: 80),
                        Text(
                          post.postTitle.length > 8 ? '${post.postTitle.substring(0, 8)}...' : post.postTitle,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
