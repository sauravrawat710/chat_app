import '../screens/start_new_conversation_screen.dart';
import 'single_conversation_card.dart';
import '../../view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;

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
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: const Color(0XFF25D366),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const StartNewConversationScreen())),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: const Icon(
            Icons.chat,
            textDirection: TextDirection.rtl,
          ),
        ),
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
