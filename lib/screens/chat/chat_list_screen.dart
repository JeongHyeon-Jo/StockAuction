import 'package:flutter/material.dart';
import 'package:auction/screens/chat/chat_screen.dart';
// import route
import 'package:auction/route.dart';
import 'package:go_router/go_router.dart';
// import firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// import provider
import 'package:provider/provider.dart';
import 'package:auction/providers/chat_provider.dart';
import 'package:auction/providers/auth_provider.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastActivityTime', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final chatDocs = chatSnapshot.data!.docs.where((doc) {
            final participants = List<String>.from(doc['participants']);
            return participants.contains(authProvider.currentUser?.uid);
          }).toList();

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chatData['userProfileImages'] != null &&
                                  chatData['userProfileImages'][authProvider.currentUser?.uid == chatData['participants'][0] 
                                      ? chatData['participants'][1] 
                                      : chatData['participants'][0]] != null &&
                                  chatData['userProfileImages'][authProvider.currentUser?.uid == chatData['participants'][0] 
                                      ? chatData['participants'][1] 
                                      : chatData['participants'][0]].isNotEmpty
                    ? NetworkImage(chatData['userProfileImages'][authProvider.currentUser?.uid == chatData['participants'][0] 
                        ? chatData['participants'][1] 
                        : chatData['participants'][0]])
                    : AssetImage('lib/assets/image/defaultUserProfile.png') as ImageProvider,
                ),
                title: Text(
                  chatData['usernames'][authProvider.currentUser?.uid == chatData['participants'][0] 
                    ? chatData['participants'][1] 
                    : chatData['participants'][0]]?.substring(0, chatData['usernames'][authProvider.currentUser?.uid == chatData['participants'][0] 
                    ? chatData['participants'][1] 
                    : chatData['participants'][0]].length > 15 ? 15 : chatData['usernames'][authProvider.currentUser?.uid == chatData['participants'][0] 
                    ? chatData['participants'][1]
                    : chatData['participants'][0]].length) ?? 'Unknown User',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (chatData['lastMessage'] != null && chatData['lastMessage'].length > 65)
                      ? '${chatData['lastMessage'].substring(0, 65)}...'
                      : chatData['lastMessage'] ?? '',
                ),
                onTap: () {
                  Provider.of<ChatProvider>(context, listen: false).listenToMessages(chatDocs[index].id);
                  GoRouter.of(context).push('/chat/${chatDocs[index].id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
