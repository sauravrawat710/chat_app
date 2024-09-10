import 'package:chat_app/features/chat_module/ui/screens/login_screen.dart';

import 'create_group_screen.dart';
import '../widgets/conversation_list_widget.dart';
import '../../view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with SingleTickerProviderStateMixin {
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
                context.read<ChatViewModel>().logout().then((isLoggedOut) {
                  if (isLoggedOut) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false);
                  }
                });
              }
            },
            itemBuilder: (BuildContext contesxt) {
              return [
                const PopupMenuItem(
                  value: "New group",
                  child: Text("New group"),
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
      ),
      body: const ConversationListWidget(),
    );
  }
}
