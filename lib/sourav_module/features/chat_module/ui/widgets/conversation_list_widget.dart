import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/start_new_conversation_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/single_conversation_card.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
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
      backgroundColor: const Color(0XFF111B21),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color.fromARGB(255, 90, 207, 150),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const StartNewConversationScreen())),
        child: const Icon(Icons.chat, color: Colors.black),
      ),
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
