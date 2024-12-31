import 'package:auction/config/color.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/chat_provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:auction/screens/chat/widgets/bottom_sheet_widget.dart';
import 'package:auction/screens/chat/widgets/message_bubble_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final BottomSheetWidget bottomSheetWidget = BottomSheetWidget();
  String? otherUserNickname;
  String? otherUserId;
  String? otherUserProfileImage;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final ids = widget.chatId.split('_');
    otherUserId = ids[0] == authProvider.currentUser?.uid ? ids[1] : ids[0];

    // 상대방의 닉네임과 프로필 이미지 가져오기
    authProvider.getUserNickname(otherUserId!).then((thisUserName) {
      setState(() {
        otherUserNickname = thisUserName ?? 'Unknown User';
      });
    });

    authProvider.getUserProfileImage(otherUserId!).then((profileImage) {
      setState(() {
        otherUserProfileImage = profileImage;
      });
    });

    Provider.of<ChatProvider>(context, listen: false).listenToMessages(widget.chatId);

    messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    chatProvider.setCurrentChatInfo(widget.chatId, authProvider.currentUser?.uid ?? '', authProvider.currentUserModel?.nickname ?? 'Unknown User');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                GoRouter.of(context).push('/other/profile/$otherUserId');
              },
              child: CircleAvatar(
                backgroundImage: otherUserProfileImage != null
                    ? CachedNetworkImageProvider(otherUserProfileImage!)
                    : AssetImage("lib/assets/image/defaultUserProfile.png") as ImageProvider,
                radius: 15,
              ),
            ),
            SizedBox(width: 10),
            Text('$otherUserNickname님과의 채팅'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // 메시지 올라오는 공간
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chatProvider.messages.length,
              itemBuilder: (ctx, index) {
                final message = chatProvider.messages[index];
                return MessageBubble(
                  message.text,
                  message.uId == authProvider.currentUser?.uid,
                  message.profileImageUrl,
                  imageUrl: message.imageUrl,
                  status: message.status,
                  messageType: message.messageType,
                  postTitle: message.confirmationMessage?['title'],
                  bidPrice: message.confirmationMessage?['bidPrice'],
                  postContent: message.confirmationMessage?['postContent'],
                  onPositivePressed: () {
                    chatProvider.handlePositiveButton(context, message, widget.chatId);
                  },
                  onNegativePressed: () async {
                    chatProvider.handleNegativeButton(message, widget.chatId, context);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                // 더하기 버튼
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    bottomSheetWidget.showBottomSheetMenu(
                      parentContext: context,
                      chatId: widget.chatId,
                      userId: authProvider.currentUser?.uid ?? '',
                      otherUserId: otherUserId!,
                      currentUserProfileImage: authProvider.currentUserModel?.userProfileImage ?? '',
                      username: authProvider.currentUserModel?.nickname ?? 'Unknown User',
                    );
                  },
                ),
                // 메시지 입력 공간
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(labelText: '메시지를 입력하세요'),
                  ),
                ),
                // 메시지 보내기 버튼
                IconButton(
                  icon: Icon(Icons.send),
                  color: themeProvider.isDarkTheme ? 
                    messageController.text.isNotEmpty ? Colors.black : Colors.white : 
                    messageController.text.isNotEmpty ? Colors.white : Colors.black,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: messageController.text.isNotEmpty ? AppsColor.pastelGreen : const Color.fromARGB(0, 255, 255, 255),
                  textStyle: TextStyle(
                    color: Colors.black,
                  ),
                  side: BorderSide(
                    color: themeProvider.isDarkTheme ? 
                    messageController.text.isNotEmpty ? Colors.black : Colors.white : 
                    messageController.text.isNotEmpty ? Colors.white : Colors.black,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      Provider.of<ChatProvider>(context, listen: false).sendMessage(
                        widget.chatId,
                        authProvider.currentUser?.uid ?? '',
                        messageController.text,
                        otherUserId!,
                        authProvider.currentUserModel?.nickname ?? 'Unknown User',
                        authProvider.currentUserModel?.userProfileImage ?? '',
                      );
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
