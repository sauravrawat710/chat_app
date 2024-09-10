import '../../view_model/chat_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    chatViewModel = context.read<ChatViewModel>();
    chatViewModel.initializeVideoAgoraSDK();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(client: chatViewModel.client),
            AgoraVideoButtons(client: chatViewModel.client),
          ],
        ),
      ),
    );
  }
}
