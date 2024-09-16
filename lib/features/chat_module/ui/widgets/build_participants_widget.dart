import '../../models/domain_user.dart';
import '../../services/realtime_db_service.dart';
import '../screens/conversation_chat_screen.dart';
import '../../view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildParticipateWidget extends StatelessWidget {
  const BuildParticipateWidget({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onUserSelected,
    required this.shouldStartConversation,
  });

  final DomainUser user;
  final bool isSelected;
  final Function(bool isSelected) onUserSelected;
  final bool shouldStartConversation;

  @override
  Widget build(BuildContext context) {
    final chatVm = context.read<ChatViewModel>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onLongPress: () => onUserSelected(true),
        onTap: () {
          if (isSelected) {
            onUserSelected(false);
          } else {
            onUserSelected(true);
            if (shouldStartConversation) {
              chatVm
                  .createNewConversation(
                name: "${chatVm.currentUser!.displayName}_${user.displayName}",
                participants: [user.id],
                conversationType: ConversationType.PRIVATE,
              )
                  .then((conversation) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      ConversationChatScreen(conversations: conversation),
                ));
              });
            }
          }
        },
        child: Container(
          color: isSelected ? const Color(0xFF36454F) : null,
          child: Row(
            children: [
              Container(
                height: 46,
                width: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/56'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 24 / 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
