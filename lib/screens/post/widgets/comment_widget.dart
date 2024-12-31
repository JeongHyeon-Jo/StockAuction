import 'package:auction/models/comment_model.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CommentWidget extends StatelessWidget {
  final CommentModel commentModel;
  final String postUid;
  final bool isAuthor;

  const CommentWidget({
    Key? key,
    required this.commentModel,
    required this.postUid,
    required this.isAuthor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUserModel;
    final isCurrentUserComment = currentUser?.uid == commentModel.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push('/other/profile/${commentModel.uid}');
            },
            child: CircleAvatar(
              backgroundImage: commentModel.userProfileImage.isNotEmpty
                  ? NetworkImage(commentModel.userProfileImage)
                  : const AssetImage('lib/assets/image/defaultUserProfile.png') as ImageProvider,
              radius: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                commentModel.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (isAuthor)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '작성자',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getTimeAgo(commentModel.commentTime),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentUserComment)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (String result) {
                          if (result == 'edit') {
                            _editComment(context);
                          } else if (result == 'delete') {
                            _deleteComment(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('수정'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(commentModel.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editComment(BuildContext context) {
    final textController = TextEditingController(text: commentModel.comment);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "수정할 내용을 입력하세요"),
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('수정'),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Provider.of<PostProvider>(context, listen: false).editComment(
                  postUid,
                  commentModel.copyWith(comment: textController.text),
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteComment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('삭제'),
            onPressed: () {
              Provider.of<PostProvider>(context, listen: false).deleteComment(
                postUid,
                commentModel.id,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime commentTime) {
    final now = DateTime.now();
    final difference = now.difference(commentTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}