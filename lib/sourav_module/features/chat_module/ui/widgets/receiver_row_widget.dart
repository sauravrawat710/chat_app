import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/common_message_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class ReceiverRowView extends StatelessWidget {
  const ReceiverRowView({Key? key, required this.messageData})
      : super(key: key);

  final Message messageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 8,
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 1.0, bottom: 9.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF90C953),
              child: Consumer<ChatViewModel>(
                builder: (context, value, child) => Text(
                  value.groupMembers
                      .firstWhere((element) => element.id == messageData.sentBy)
                      .displayName
                      .characters
                      .first,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 72,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 5.0, right: 8.0, top: 4.0, bottom: 2.0),
                padding: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 4.0, bottom: 9.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0XFF1F2C33),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: CommonMessageWidget(messages: messageData),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10.0, bottom: 8.0),
                child: Text(
                  intl.DateFormat('hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(messageData.sentAt)),
                  style: const TextStyle(color: Colors.white, fontSize: 7.0),
                ),
              ),
            ],
          ),
          //
        ),
        Flexible(
          flex: 15,
          fit: FlexFit.tight,
          child: Container(
            width: 50.0,
          ),
        ),
      ],
    );
  }
}
