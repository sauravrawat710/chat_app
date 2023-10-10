import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/create_group_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/conversation_list_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("elRed"),
        backgroundColor: const Color(0xFF1F2C33).withOpacity(.92),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'New group') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen(),
                ));
              }
              if (value == 'Logout') {
                context.read<ChatViewModel>().loginOrLogout();
              }
            },
            itemBuilder: (BuildContext contesxt) {
              return [
                const PopupMenuItem(
                  value: "New group",
                  child: Text("New group"),
                ),
                const PopupMenuItem(
                  value: "New broadcast",
                  child: Text("New broadcast"),
                ),
                const PopupMenuItem(
                  value: "Whatsapp Web",
                  child: Text("Whatsapp Web"),
                ),
                const PopupMenuItem(
                  value: "Starred messages",
                  child: Text("Starred messages"),
                ),
                const PopupMenuItem(
                  value: "Settings",
                  child: Text("Settings"),
                ),
                const PopupMenuItem(
                  value: "Logout",
                  child: Text("Logout"),
                ),
              ];
            },
          )
        ],
        // bottom: TabBar(
        //   controller: _controller,
        //   indicatorColor: Colors.greenAccent,
        //   labelColor: Colors.greenAccent,
        //   unselectedLabelColor: Colors.white,
        //   tabs: const [
        //     Tab(icon: Icon(Icons.camera_alt)),
        //     Tab(text: "Chats"),
        //     Tab(text: "Status"),
        //     Tab(text: "Calls")
        //   ],
        // ),
      ),
      // body: TabBarView(
      //   controller: _controller,
      //   children: const [
      //     Center(child: Text("CAMERA")),
      //     ConversationListWidget(),
      //     Center(child: Text("STATUS")),
      //     Center(child: Text("CALLS")),
      //   ],
      // ),
      body: const ConversationListWidget(),
    );
  }
}
