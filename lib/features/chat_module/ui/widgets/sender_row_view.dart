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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 8.0, right: 5.0, top: 8.0, bottom: 2.0),
                padding: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 9.0, bottom: 9.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0XFF075E54),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: CommonMessageWidget(messages: widget.messageData),
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
                        // if (widget.messageData.seenBy.isNotEmpty)
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
          const SizedBox(width: 10),
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
                  backgroundColor: const Color(0xFF1F2C33).withOpacity(.92),
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
                          child: const Text('Edit'),
                        ),
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
