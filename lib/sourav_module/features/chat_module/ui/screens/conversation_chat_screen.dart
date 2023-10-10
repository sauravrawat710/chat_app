import 'package:agora_chat_module/sourav_module/features/chat_module/models/conversations.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/video_call_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/voice_call_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/bottom_typing_text_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/chat_list_view.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/typing_indicator.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ConversationChatScreen extends StatefulWidget {
  const ConversationChatScreen({super.key, required this.conversations});

  final Conversations conversations;

  @override
  State<ConversationChatScreen> createState() => _ConversationChatScreenState();
}

class _ConversationChatScreenState extends State<ConversationChatScreen> {
  late final ChatViewModel chatvm;

  late final TextEditingController textEditingController;
  late String senderMessage, receiverMessage;
  late final ScrollController scrollController;

  @override
  void initState() {
    chatvm = context.read<ChatViewModel>();
    textEditingController = TextEditingController();
    textEditingController.addListener(chatvm.detectUserMention);
    scrollController = ScrollController();
    chatvm.setupControllers(
      textEditingController: textEditingController,
      scrollController: scrollController,
    );
    chatvm.fetchGroupConversationMembers(widget.conversations.id);
    // chatvm.fetchConversationByConversationId();

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36454F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C33).withOpacity(.92),
        leadingWidth: 50.0,
        titleSpacing: -8.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Consumer<ChatViewModel>(
              builder: (context, value, child) => Icon(
                widget.conversations.type == 'group'
                    ? Icons.group
                    : Icons.person,
                color: Colors.grey[200],
              ),
            ),
          ),
        ),
        title: Consumer<ChatViewModel>(
          builder: (context, value, child) => ListTile(
            title: Text(
              value.getSelectedConversation.type == 'private'
                  ? value.getSelectedConversation.name.split('_').firstWhere(
                      (element) => element != value.currentUser!.displayName)
                  : value.getSelectedConversation.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: widget.conversations.type == 'group'
                ? Row(
                    children: value.groupMembers.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(e.displayName,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  )
                : null,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VideoCallScreen()),
            ),
            child: const Icon(Icons.videocam),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VoiceCallScreen()),
              ),
              child: const Icon(Icons.call),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: .1,
            colorFilter: ColorFilter.mode(
              Color(0XFF0C151B),
              BlendMode.difference,
            ),
            image: NetworkImage(
                "https://camo.githubusercontent.com/854a93c27d64274c4f8f5a0b6ec36ee1d053cfcd934eac6c63bed9eaef9764bd/68747470733a2f2f7765622e77686174736170702e636f6d2f696d672f62672d636861742d74696c652d6461726b5f61346265353132653731393562366237333364393131306234303866303735642e706e67"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: ChatListView(scrollController: scrollController)),
            Consumer<ChatViewModel>(
              builder: (context, value, child) {
                if (value.filteredSuggestions.isNotEmpty) {
                  return Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: value.filteredSuggestions.length > 5
                        ? MediaQuery.of(context).size.height / 2.5
                        : null,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: value.filteredSuggestions.map((name) {
                        return ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () => chatvm.onUserMentionTap(name: name),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Selector<ChatViewModel, bool>(
              selector: (context, value) => value.shouldShowTypingIndicator,
              builder: (context, value, child) => TypingIndicator(
                showIndicator: value,
              ),
            ),
            BottomTypingTextWidget(textEditingController: textEditingController)
          ],
        ),
      ),
    );
  }
}
