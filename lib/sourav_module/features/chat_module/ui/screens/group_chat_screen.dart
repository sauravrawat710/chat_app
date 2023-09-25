import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/video_call_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/bottom_typing_text_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/chat_list_view.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/typing_indicator.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
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
    chatvm.fetchGroupConversationMembers();
    chatvm.fetchConversationByConversationId();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        backgroundColor: const Color(0xFF1F2C33),
        leadingWidth: 50.0,
        titleSpacing: -8.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Consumer<ChatViewModel>(
                builder: (context, value, child) =>
                    Icon(Icons.group, color: Colors.grey[200])),
          ),
        ),
        title: Consumer<ChatViewModel>(
          builder: (context, value, child) => ListTile(
            title: Text(
              value.selectedConversationName,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Row(
              children: value.groupMembers.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(e.displayName,
                      style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
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
          const Padding(
            padding: EdgeInsets.only(right: 20.0, left: 20.0),
            child: Icon(Icons.call),
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
                      // mainAxisSize: MainAxisSize.min,
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
