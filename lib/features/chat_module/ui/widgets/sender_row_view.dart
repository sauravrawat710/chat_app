import '../../models/messages.dart';
import 'common_message_widget.dart';
import '../../view_model/chat_view_model.dart';
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
    late Offset offset;
    final chatVm = context.read<ChatViewModel>();
    return GestureDetector(
      onTapDown: (TapDownDetails details) => offset = details.globalPosition,
      onLongPress: () => _showPopupMenu(context: context, offset: offset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0XFF128C7E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: CommonMessageWidget(messages: widget.messageData),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
                width: 20,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
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
                    // if (widget.messageData.seenBy.isNotEmpty)
                    Positioned(
                      bottom: 0,
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  intl.DateFormat('hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.messageData.sentAt)),
                  style: const TextStyle(
                    color: Color(0XFFB3B3B3),
                    fontSize: 8.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showPopupMenu({
    required BuildContext context,
    required Offset offset,
  }) {
    final screenSize = MediaQuery.of(context).size;
    return showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      ),
      items: [
        if (widget.messageData.type == MessageType.TEXT)
          PopupMenuItem(
            onTap: () {
              showBottomSheet(
                context: context,
                builder: (context) => BottomSheet(
                  // backgroundColor: const Color(0xFF1F2C33).withOpacity(.92),
                  onClosing: () {},
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.messageData.text,
                          // cursorColor: Colors.white,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.black38),
                            fillColor: Colors.blueGrey,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ), // Customize border
                            ),
                          ),
                          onChanged: (value) => updatedMessage = value,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF075E54)),
                          onPressed: () {
                            context.read<ChatViewModel>().editMessage(widget
                                .messageData
                                .copyWith(text: updatedMessage));
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.black),
            ),
          ),
        PopupMenuItem(
          onTap: () async {
            await context
                .read<ChatViewModel>()
                .deleteMessage(widget.messageData.id);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
