import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/receiver_row_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/sender_row_view.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({Key? key, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, value, child) => ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: scrollController,
        itemCount: value.messageList.length,
        itemBuilder: (context, index) {
          return (value.messageList[index].isSender)
              ? SenderRowView(messageData: value.messageList[index])
              : ReceiverRowView(messageData: value.messageList[index]);
        },
      ),
    );
  }
}
