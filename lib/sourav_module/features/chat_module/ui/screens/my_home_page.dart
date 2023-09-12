import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ChatViewModel chatvm;
  @override
  void initState() {
    chatvm = context.read<ChatViewModel>();
    chatvm.setupChatClient();
    chatvm.setupListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat App')),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Consumer<ChatViewModel>(
                      builder: (context, value, child) => TextField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter recipient's userId",
                        ),
                        onChanged: (chatUserId) =>
                            chatvm.recipientId = chatUserId,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: Consumer<ChatViewModel>(
                    builder: (context, value, child) {
                      return ElevatedButton(
                        onPressed: chatvm.joinLeave,
                        child: Text(chatvm.isJoined ? "Leave" : "Join"),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, value, child) => ListView.builder(
                  controller: chatvm.scrollController,
                  itemCount: chatvm.messageList.length,
                  itemBuilder: (_, index) {
                    return chatvm.messageList[index];
                  },
                ),
              ),
            ),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: chatvm.messageBoxController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Message",
                    ),
                    onChanged: (msg) => chatvm.messageContent = msg,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 50,
                height: 40,
                child: ElevatedButton(
                  onPressed: chatvm.sendMessage,
                  child: const Text(">>"),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
