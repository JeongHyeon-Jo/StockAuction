import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/chat_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auction/utils/permissions_util.dart';
import 'package:auction/utils/custom_alert_dialog.dart';
import 'package:auction/models/post_model.dart';

class BottomSheetWidget {
  final ImagePicker _picker = ImagePicker();

  void showBottomSheetMenu({
    required BuildContext parentContext,
    required String chatId,
    required String userId,
    required String otherUserId,
    required String currentUserProfileImage,
    required String username,
  }) {
    final chatProvider = Provider.of<ChatProvider>(parentContext, listen: false);

    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.gavel),
              title: Text('거래 확정 버튼 보내기'),
              onTap: () async {
                Navigator.pop(context);
                List<PostModel> posts = await chatProvider.fetchConfirmablePosts(userId, otherUserId);

                if (posts.isEmpty) {
                  showDialog(
                    context: parentContext,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('알림'),
                        content: Text('해당 조건에 맞는 구매 확정 가능한 상품이 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                showModalBottomSheet(
                  context: parentContext,
                  builder: (BuildContext context) {
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        PostModel post = posts[index];
                        int maxTitleLength = 15;
                        int maxContentLength = 65;

                        // 제목과 내용에 최대 글자 수 적용
                        String displayTitle = post.postTitle.length > maxTitleLength
                            ? post.postTitle.substring(0, maxTitleLength) + '...'
                            : post.postTitle;
                        
                        String displayContent = post.postContent.length > maxContentLength
                            ? post.postContent.substring(0, maxContentLength) + '...'
                            : post.postContent;
                        return ListTile(
                          leading: post.postImageList.isNotEmpty
                              ? Image.network(post.postImageList[0], width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.image_not_supported),
                          title: Text(displayTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )),
                          subtitle: Text(displayContent),
                          onTap: () {
                            Navigator.pop(context);
                            chatProvider.sendConfirmationMessage(post, chatId, userId, otherUserId, username);
                          },
                        );
                      },
                    );
                  },
                );
              }
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('갤러리에서 사진 보내기'),
              onTap: () async {
                Navigator.pop(context);

                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  _showConfirmationDialog(parentContext, image, chatId, userId, otherUserId, currentUserProfileImage, username);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('카메라로 사진 찍고 보내기'),
              onTap: () async {
                Navigator.pop(context);

                bool hasPermission = await PermissionsUtil.requestCameraPermission();
                if (!hasPermission) {
                  showCustomAlertDialog(
                    context: parentContext,
                    title: "권한 필요",
                    message: "이 작업을 위해서는 카메라 접근 권한이 필요합니다.",
                    positiveButtonText: "확인",
                  );
                  return;
                }

                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  _showConfirmationDialog(parentContext, image, chatId, userId, otherUserId, currentUserProfileImage, username);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    XFile image,
    String chatId,
    String userId,
    String otherUserId,
    String currentUserProfileImage,
    String username,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사진 보내기'),
          content: Image.file(File(image.path)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                final chatProvider = Provider.of<ChatProvider>(context, listen: false);

                chatProvider.sendImageMessage(
                  chatId,
                  userId,
                  image,
                  username,
                  otherUserId,
                  currentUserProfileImage,
                );
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }
}
