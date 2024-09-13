import '../../models/messages.dart';
import 'common_message_widget.dart';
import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;

class ReceiverRowView extends StatelessWidget {
  const ReceiverRowView({Key? key, required this.messageData})
      : super(key: key);

  final Message messageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Flexible(
        //   flex: 8,
        //   fit: FlexFit.tight,
        //   child: Padding(
        //     padding: const EdgeInsets.only(left: 10.0, top: 1.0, bottom: 9.0),
        //     child: CircleAvatar(
        //       backgroundColor: const Color(0xFF90C953),
        //       child: Consumer<ChatViewModel>(
        //         builder: (context, value, child) => Text(
        //           value.groupMembers
        //               .firstWhere((element) => element.id == messageData.sentBy)
        //               .displayName
        //               .characters
        //               .first,
        //           style: const TextStyle(
        //             color: Colors.black,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Flexible(
          flex: 72,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Color(0XFFDEDEDE),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: CommonMessageWidget(messages: messageData),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  timeago.format(DateTime.fromMillisecondsSinceEpoch(
                    messageData.sentAt,
                  )),
                  style:
                      const TextStyle(color: Color(0XFFB3B3B3), fontSize: 7.0),
                ),
              ),
            ],
          ),
          //
        ),
        Flexible(
          flex: 15,
          fit: FlexFit.tight,
          child: Container(width: 50.0),
        ),
      ],
    );
  }
}
