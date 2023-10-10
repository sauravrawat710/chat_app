import 'package:agora_chat_module/sourav_module/features/chat_module/models/domain_user.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/services/realtime_db_service.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/conversation_chat_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildParticipateWidget extends StatelessWidget {
  const BuildParticipateWidget({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onUserSelected,
  });

  final DomainUser user;
  final bool isSelected;
  final Function(bool isSelected) onUserSelected;

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
        },
        child: Container(
          padding: const EdgeInsets.all(18.0),
          color: isSelected ? const Color(0xFF36454F) : null,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blueGrey,
                radius: 22,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                user.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
