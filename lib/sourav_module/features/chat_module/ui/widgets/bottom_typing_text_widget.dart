import 'dart:developer';

import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/services/realtime_db_service.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BottomTypingTextWidget extends StatefulWidget {
  const BottomTypingTextWidget(
      {super.key, required this.textEditingController});

  final TextEditingController textEditingController;

  @override
  State<BottomTypingTextWidget> createState() => _BottomTypingTextWidgetState();
}

class _BottomTypingTextWidgetState extends State<BottomTypingTextWidget>
    with WidgetsBindingObserver {
  bool shouldEnable = false;

  late final ChatViewModel chatvm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    chatvm = context.read<ChatViewModel>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      chatvm.showTypingIndicator();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color(0XFF1F2C33),
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 12.0),
                  child: const Icon(
                    Icons.emoji_emotions,
                    color: Color(0XFF8696A0),
                  ),
                ),
                Expanded(
                  child: Consumer<ChatViewModel>(
                    builder: (context, viewModel, child) => TextFormField(
                      controller: widget.textEditingController,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _shouldEnableSendButton();
                        if (!viewModel.shouldShowTypingIndicator) {
                          viewModel.showTypingIndicator(true);
                          Future.delayed(const Duration(seconds: 4))
                              .whenComplete(() {
                            viewModel.showTypingIndicator();
                          });
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    bottom: 11.0,
                  ),
                  child: Consumer<ChatViewModel>(
                    builder: (context, value, child) {
                      if (value.messageStatus == MessageStatus.SENDING) {
                        return const Center(
                            child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ));
                      }
                      return Transform.rotate(
                        angle: -3.14 / 5,
                        child: GestureDetector(
                          onTap: () => _showAttachmentPopup(context),
                          child: const Icon(
                            Icons.attach_file_outlined,
                            color: Color(0XFF8696A0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: const Color(0XFF075E54),
          child: GestureDetector(
            onTap: shouldEnable
                ? () => chatvm.sendMessage(MessageType.TEXT)
                : null,
            child: const Icon(Icons.send, color: Colors.white70),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  void _shouldEnableSendButton() {
    if (widget.textEditingController.text.isNotEmpty) {
      shouldEnable = true;
    } else {
      shouldEnable = false;
    }
    setState(() {});
  }

  void _showAttachmentPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                chatvm.pickImageAndSend(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () {
                chatvm.pickImageAndSend(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_document),
              title: const Text('Document'),
              onTap: () {
                chatvm.pickFileAndSent();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Contact'),
              onTap: () {
                chatvm.pickContactAndSent();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Audio'),
              onTap: () {
                chatvm.pickAudioAndSent();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location'),
              onTap: () {
                chatvm.pickContactAndSent();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
