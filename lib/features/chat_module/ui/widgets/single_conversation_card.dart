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
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          height: 56,
          width: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/56'),
            ),
          ),
        ),
        title: Text(
          conversations.type == 'private'
              ? conversations.name.split('_').firstWhere(
                  (element) => element != chatVm.currentUser?.displayName)
              : conversations.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 24 / 16,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversations.recentMessage.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0XFFB9BAC7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeago.format(DateTime.fromMillisecondsSinceEpoch(
                conversations.recentMessage.readBy.sentAt,
              )),
              style: const TextStyle(fontSize: 12, color: Color(0XFF128C7E)),
            ),
            const SizedBox(height: 2),
            const CircleAvatar(
              radius: 10,
              backgroundColor: Color(0XFF128C7E),
              child: Text(
                '2',
                style: TextStyle(
                  fontSize: 11,
                  height: 16.5 / 11,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
