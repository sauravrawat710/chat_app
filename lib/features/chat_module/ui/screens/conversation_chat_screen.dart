import '../../models/conversations.dart';
import 'video_call_screen.dart';
import 'voice_call_screen.dart';
import '../widgets/bottom_typing_text_widget.dart';
import '../widgets/chat_list_view.dart';
import '../widgets/typing_indicator.dart';
import '../../view_model/chat_view_model.dart';
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

  final TextEditingController textEditingController = TextEditingController();
  late String senderMessage, receiverMessage;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    chatvm = context.read<ChatViewModel>();
    textEditingController.addListener(chatvm.detectUserMention);

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
    final vm = context.read<ChatViewModel>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(
              Icons.arrow_back_ios,
              size: 28,
            ),
          ),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: Container(color: const Color(0XFFC4C4C4), height: .2)),
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/56'),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  vm.getSelectedConversation.type == 'private'
                      ? vm.getSelectedConversation.name.split('_').firstWhere(
                          (element) => element != vm.currentUser?.displayName)
                      : vm.getSelectedConversation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Today at 2:30 pm'),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VoiceCallScreen()),
            ),
            child: const Icon(Icons.call_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VideoCallScreen()),
              ),
              child: const Icon(Icons.videocam_outlined, size: 28),
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
