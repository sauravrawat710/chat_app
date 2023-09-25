import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final ChatViewModel chatViewModel;
  late final AgoraClient client;

// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();
    chatViewModel = context.read<ChatViewModel>();
    // Instantiate the client
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: chatViewModel.appId,
        channelName: chatViewModel.getSelectedConversation.name,
      ),
    );
    initAgora(client);
  }

  void initAgora(AgoraClient client) async {
    await client.initialize();
  }

// Build your layout
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(client: client),
              AgoraVideoButtons(client: client),
            ],
          ),
        ),
      ),
    );
  }
}
