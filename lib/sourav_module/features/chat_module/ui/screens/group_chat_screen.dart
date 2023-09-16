import 'dart:developer';

import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/chat_list_view.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/typing_indicator.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late final ChatViewModel chatvm;

  late final TextEditingController textEditingController;
  late String senderMessage, receiverMessage;
  ScrollController scrollController = ScrollController();
  bool shouldEnable = false;
  final List<String> _suggestions = ['John', 'Jane', 'Jim', 'Jill'];
  String? _mention;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingController.addListener(() {
      setState(() {
        final text = textEditingController.text;
        final index = text.lastIndexOf('@');
        if (index >= 0 && index < text.length - 1) {
          final mention = text.substring(index + 1);
          if (mention != _mention) {
            _mention = mention;
            _filteredSuggestions = _suggestions
                .where((name) => name.startsWith(_mention!))
                .toList();
          }
        } else {
          _mention = null;

          _filteredSuggestions = [];
        }
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    chatvm = context.read<ChatViewModel>();
    chatvm.setupControllers(
      textEditingController: textEditingController,
      scrollController: scrollController,
    );
    chatvm.fetchPreviousMessages();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36454F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF36454F),
        leadingWidth: 50.0,
        titleSpacing: -8.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF90C953),
            child: Consumer<ChatViewModel>(
              builder: (context, value, child) => Text(
                value.getSelectedGroupChat.name!.characters.first,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        title: Consumer<ChatViewModel>(
          builder: (context, value, child) => ListTile(
            title: Text(value.getSelectedGroupChat.name ?? '',
                style: const TextStyle(color: Colors.white)),
          ),
        ),
        actions: const [
          Icon(Icons.videocam),
          Padding(
            padding: EdgeInsets.only(right: 20.0, left: 20.0),
            child: Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ChatListView(scrollController: scrollController)),
          if (_filteredSuggestions.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (ontext, index) {
                    return ListTile(
                      tileColor: const Color.fromARGB(255, 80, 99, 111),
                      title: Text(
                        _filteredSuggestions[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        final mention = _filteredSuggestions[index];
                        final text = textEditingController.text;
                        final indexs = text.lastIndexOf('@');
                        textEditingController.value = TextEditingValue(
                          text: text.substring(0, indexs + 1) + mention,
                          selection: TextSelection.collapsed(
                            offset: text.length,
                          ),
                        );
                        setState(() {
                          _filteredSuggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          Selector<ChatViewModel, bool>(
            selector: (context, value) => value.shouldShowTypingIndicator,
            builder: (context, value, child) => TypingIndicator(
              showIndicator: value,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color.fromARGB(255, 80, 99, 111),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _showMultiMediaPopupMenu(context),
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 12.0),
                    child: Transform.rotate(
                        angle: 45,
                        child: const Icon(
                          Icons.attach_file_sharp,
                          color: Colors.white,
                        )),
                  ),
                ),
                Expanded(
                  child: Consumer<ChatViewModel>(
                    builder: (context, viewModel, child) => TextFormField(
                      controller: textEditingController,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
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
                      left: 8.0, right: 8.0, bottom: 11.0),
                  child: Transform.rotate(
                    angle: -3.14 / 5,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: GestureDetector(
                        onTap: shouldEnable ? chatvm.sendMessage : null,
                        child: Icon(
                          Icons.send,
                          color: shouldEnable ? Colors.white : Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shouldEnableSendButton() {
    if (textEditingController.text.isNotEmpty) {
      shouldEnable = true;
    } else {
      shouldEnable = false;
    }
    setState(() {});
  }

  Future<dynamic> _showMultiMediaPopupMenu(BuildContext context) {
    return showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 670, 100, 0),
      items: [
        PopupMenuItem(
          onTap: chatvm.pickImageAndSend,
          child: const Text('Images'),
        ),
        PopupMenuItem(
          onTap: chatvm.pickFileAndSent,
          child: const Text('Files'),
        ),
        PopupMenuItem(
          onTap: chatvm.pickContactAndSent,
          child: const Text('Contacts'),
        ),
      ],
    );
  }
}
