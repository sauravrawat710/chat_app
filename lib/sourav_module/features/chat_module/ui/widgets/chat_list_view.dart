import 'dart:developer';

import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/services/realtime_db_service.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/receiver_row_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/sender_row_view.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key? key, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, value, child) => FirebaseDatabaseListView(
        query: RealtimeDBService()
            .db
            .ref('messages/${value.getSelectedConversation.id}'),
        pageSize: 20,
        itemBuilder: (context, doc) {
          Message? messages;
          messages = _parseMessages(doc, value, messages);
          if (messages == null) {
            return const SizedBox.shrink();
          }
          return messages.isSender
              ? SenderRowView(messageData: messages)
              : ReceiverRowView(messageData: messages);
        },
      ),
    );
  }

  Message? _parseMessages(
    DataSnapshot doc,
    ChatViewModel value,
    Message? messages,
  ) {
    if (doc.value != null) {
      final mapOfData = Map<String, dynamic>.from(doc.value as Map);
      Message message = Message.fromJson(mapOfData);

      final isSender = message.sentBy == value.user!.uid;

      message = message.copyWith(isSender: isSender);

      if (!message.seenBy.contains(value.user!.uid)) {
        value.markMessageAsRead(message);
      }

      messages = message;
    }
    return messages;
  }
}
