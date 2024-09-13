import 'single_conversation_card.dart';
import '../../view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationListWidget extends StatefulWidget {
  const ConversationListWidget({Key? key}) : super(key: key);

  @override
  State<ConversationListWidget> createState() => _ConversationListWidgetState();
}

class _ConversationListWidgetState extends State<ConversationListWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().fetchConversations();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChatViewModel>(
        builder: (context, value, child) {
          if (value.conversationsList.isEmpty) {
            return Center(
              child: Text(
                'No Conversation yet.',
                style: TextStyle(color: Colors.blueGrey[200]),
              ),
            );
          }
          return ListView.builder(
            itemCount: value.conversationsList.length,
            itemBuilder: (contex, index) => SingleConversationCard(
              conversations: value.conversationsList[index],
            ),
          );
        },
      ),
    );
  }
}
