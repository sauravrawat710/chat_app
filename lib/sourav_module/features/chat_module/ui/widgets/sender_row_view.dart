import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/common_message_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class SenderRowView extends StatefulWidget {
  const SenderRowView({Key? key, required this.messageData}) : super(key: key);

  final Message messageData;

  @override
  State<SenderRowView> createState() => _SenderRowViewState();
}

class _SenderRowViewState extends State<SenderRowView> {
  late String updatedMessage = '';

  @override
  void initState() {
    updatedMessage = widget.messageData.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).size.height * .2;
    final chatVm = context.read<ChatViewModel>();
    return GestureDetector(
      onLongPress: () => _showPopupMenu(context, top),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            flex: 15,
            fit: FlexFit.tight,
            child: Container(
              width: 50.0,
            ),
          ),
          Flexible(
            flex: 72,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          left: 8.0, right: 5.0, top: 8.0, bottom: 2.0),
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 9.0, bottom: 9.0),
                      decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Color(0XFF075E54),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: CommonMessageWidget(messages: widget.messageData),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10.0, bottom: 8.0),
                      child: Text(
                        intl.DateFormat('hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                widget.messageData.sentAt)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      width: 20,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 10,
                            child: Icon(
                              Icons.check,
                              color: (widget.messageData.seenBy.length ==
                                      chatVm.groupMembers.length)
                                  ? Colors.blue
                                  : Colors.white,
                              size: 12,
                            ),
                          ),
                          if (widget.messageData.seenBy.isNotEmpty)
                            Positioned(
                              left: 2,
                              child: Icon(
                                Icons.check,
                                color: (widget.messageData.seenBy.length ==
                                        chatVm.groupMembers.length)
                                    ? Colors.blue
                                    : Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Future<dynamic> _showPopupMenu(BuildContext context, double top) {
    return showMenu(
      context: context,
      position: RelativeRect.fromLTRB(50, top, 0, 0),
      items: [
        PopupMenuItem(
          onTap: () {
            showBottomSheet(
              context: context,
              builder: (context) => BottomSheet(
                onClosing: () {},
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.messageData.text,
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 6,
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.black38),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => updatedMessage = value,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChatViewModel>().editMessage(
                            widget.messageData.copyWith(text: updatedMessage));
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Text('Edit'),
        ),
        PopupMenuItem(
          onTap: () async {
            await context
                .read<ChatViewModel>()
                .deleteMessage(widget.messageData.id);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
