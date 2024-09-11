import 'dart:developer';

import '../../models/conversations.dart';
import '../screens/conversation_chat_screen.dart';
import '../../view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class SingleConversationCard extends StatelessWidget {
  const SingleConversationCard({Key? key, required this.conversations})
      : super(key: key);
  final Conversations conversations;

  @override
  Widget build(BuildContext context) {
    final chatVm = context.read<ChatViewModel>();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) =>
                ConversationChatScreen(conversations: conversations),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.blueGrey,
              child: Icon(
                conversations.type == 'group' ? Icons.group : Icons.person,
                size: 36,
                color: Colors.white,
              ),
            ),
            title: Text(
              conversations.type == 'private'
                  ? conversations.name.split('_').firstWhere(
                      (element) => element != chatVm.currentUser?.displayName)
                  : conversations.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.done_all,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 3),
                Text(
                  conversations.recentMessage.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: Text(
              timeago.format(DateTime.fromMillisecondsSinceEpoch(
                conversations.recentMessage.readBy.sentAt,
              )),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
