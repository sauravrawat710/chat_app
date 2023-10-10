import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/conversation_list_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/login_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().checkIfUserLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, value, child) {
        if (value.isJoined && !value.isLoading) {
          return const ConversationListScreen();
        }
        if (value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
