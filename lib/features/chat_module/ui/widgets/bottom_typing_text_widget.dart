import 'package:chat_app/features/chat_module/models/messages.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../services/realtime_db_service.dart';
import '../../view_model/chat_view_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  late final ChatViewModel chatvm;
  bool shouldShowEmoji = false;
  bool shouldShowAttachment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.textEditingController.addListener(() {
      setState(() {});
    });
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
    return Column(
      children: [
        Container(
          height: 72,
          color: const Color(0XFF1F1F1F),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              // color: Color(0XFF1F2C33),
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    if (shouldShowAttachment) {
                      setState(() {
                        shouldShowAttachment = false;
                      });
                    }
                    setState(() {
                      shouldShowEmoji = !shouldShowEmoji;
                    });
                  },
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: shouldShowEmoji
                        ? const Color(0XFF128C7E)
                        : const Color(0XFF575757),
                  ),
                ),
                const SizedBox(width: 10),
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
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Color(0XFF797979)),
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        if (shouldShowEmoji) {
                          setState(() {
                            shouldShowEmoji = false;
                          });
                        }
                      },
                      onChanged: (value) {
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
                Transform.rotate(
                  angle: 3.14 / 5,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (shouldShowEmoji) {
                        shouldShowEmoji = false;
                      }
                      shouldShowAttachment = !shouldShowAttachment;
                    }),
                    child: Icon(
                      Icons.attach_file_outlined,
                      color: shouldShowAttachment
                          ? const Color(0XFF128C7E)
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.textEditingController.text.isEmpty) ...[
                  Consumer<ChatViewModel>(
                    builder: (context, value, child) {
                      if (value.messageStatus == MessageStatus.SENDING) {
                        return const Center(
                            child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ));
                      } else {
                        return GestureDetector(
                          // onTap: () => _showAttachmentPopup(context),
                          child: const Icon(
                            Icons.mic_none_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        );
                      }
                    },
                  ),
                ] else ...[
                  CircleAvatar(
                    backgroundColor: const Color(0XFF128C7E),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          shouldShowAttachment = false;
                          shouldShowEmoji = false;
                        });
                        chatvm.sendMessage(MessageType.TEXT);
                      },
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
        if (shouldShowEmoji)
          SizedBox(
            height: MediaQuery.of(context).size.height / 3.4,
            child: EmojiPicker(
              textEditingController: widget.textEditingController,
              onEmojiSelected: (category, emoji) => setState(() {}),
              onBackspacePressed: () => setState(() {}),
              config: Config(
                columns: 7,
                emojiSizeMax: 32 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.30
                        : 0.8),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                initCategory: Category.RECENT,
                bgColor: const Color(0XFF1F1F1F).withOpacity(.7),
                indicatorColor: const Color(0XFF128C7E),
                iconColor: Colors.grey,
                iconColorSelected: const Color(0XFF128C7E),
                backspaceColor: const Color(0XFF128C7E),
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                recentTabBehavior: RecentTabBehavior.RECENT,
                recentsLimit: 28,
                noRecents: const Text(
                  'No Recents',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ), // Needs to be const Widget
                loadingIndicator:
                    const SizedBox.shrink(), // Needs to be const Widget
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL,
              ),
            ),
          ),
        if (shouldShowAttachment)
          Container(
            height: MediaQuery.of(context).size.height / 3.4,
            width: MediaQuery.of(context).size.width,
            color: const Color(0XFF1F1F1F).withOpacity(.3),
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 40,
              spacing: 60,
              children: [
                GestureDetector(
                  onTap: () async {
                    await chatvm.pickImageAndSend(ImageSource.gallery);
                    setState(() {
                      shouldShowAttachment = false;
                      shouldShowEmoji = false;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0XFF121B22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.photo_album_outlined,
                          color: Color(0XFF007CFA),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Gallery')
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await chatvm.pickImageAndSend(ImageSource.camera);
                    setState(() {
                      shouldShowAttachment = false;
                      shouldShowEmoji = false;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0XFF121B22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0XFFFF2C74),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Camera')
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await chatvm.pickLocationAndSent();
                    setState(() {
                      shouldShowAttachment = false;
                      shouldShowEmoji = false;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0XFF121B22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0XFF0CCD9B),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Location')
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await chatvm.pickContactAndSent();
                    setState(() {
                      shouldShowAttachment = false;
                      shouldShowEmoji = false;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0XFF121B22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.contacts_outlined,
                          color: Color(0XFF009DE5),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Contact')
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await chatvm.pickFileAndSent();
                    setState(() {
                      shouldShowAttachment = false;
                      shouldShowEmoji = false;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0XFF121B22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.file_present_outlined,
                          color: Color(0XFF8063FF),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Document')
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await chatvm.pickAudioAndSent();
                    setState(() {
                      shouldShowAttachment = false;
                      shouldShowEmoji = false;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0XFF121B22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.audiotrack_outlined,
                          color: Color(0XFFFE6334),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Audio')
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
