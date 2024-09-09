import 'dart:developer';

import '../../services/realtime_db_service.dart';
import '../../view_model/chat_view_model.dart';
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<ChatViewModel>(
                  builder: (context, value, child) {
                    return Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: value.listOfRemoteUserJoined.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40, // Adjust the size as needed
                                    backgroundColor:
                                        Colors.white, // Customize the color
                                    child: Text(
                                      value.currentUser!.displayName.characters
                                          .first,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "You",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }
                          final user = value.listOfRemoteUserJoined[index - 1];

                          return Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.blue, width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40, // Adjust the size as needed
                                  backgroundColor:
                                      Colors.blue, // Customize the color
                                  child: Text(
                                    user.displayName.characters.first,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  user.displayName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
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
