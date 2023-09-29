import 'dart:developer';

import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late final ChatViewModel chatVm;

  @override
  void initState() {
    chatVm = context.read<ChatViewModel>();
    chatVm.setupAudioSDKEngine().then((value) {
      chatVm.join();
    });
    super.initState();
  }

  @override
  void dispose() {
    chatVm.disposeAudioAgora();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2C33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C33),
        title: Text(chatVm.getSelectedConversation.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: chatVm.leaveAudioCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display participant names or avatars
                Consumer<ChatViewModel>(
                  builder: (context, value, child) => Text(
                    "Participants: ${value.listOfRemoteUserJoined.length + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Speaker's name and microphone status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Selector<ChatViewModel, bool>(
                      selector: (p0, p1) => p1.isMuted,
                      builder: (context, isMute, child) => Text(
                        isMute
                            ? "You're on mute!"
                            : 'You are speaking: ${chatVm.currentUser?.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Speaker volume indicator
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Consumer<ChatViewModel>(
                    builder: (context, value, child) => FractionallySizedBox(
                      // widthFactor: 0.7,
                      widthFactor: value.speakerVolume.toDouble(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controls for muting and leaving the call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Selector<ChatViewModel, bool>(
                selector: (p0, p1) => p1.isMuted,
                builder: (context, isMute, child) => ElevatedButton(
                  onPressed: () => chatVm.onMuteClicked(!isMute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMute ? Colors.red : Colors.green,
                    shape: const CircleBorder(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isMute ? Icons.mic_off : Icons.mic,
                      size: 32,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                ),
                onPressed: chatVm.leaveAudioCall,
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Icon(
                    Icons.call_end,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
