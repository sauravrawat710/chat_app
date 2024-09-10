import 'package:flutter/material.dart';

class SingleChatTextWidget extends StatelessWidget {
  const SingleChatTextWidget({
    super.key,
    required this.isSentMessage,
    required this.text,
  });

  final bool isSentMessage;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment:
                isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(
                  (isSentMessage ? 50 : 0), 5, (isSentMessage ? 0 : 50), 5),
              decoration: BoxDecoration(
                  color: isSentMessage ? Colors.blue[100] : Colors.blue,
                  borderRadius: BorderRadius.circular(14)),
              child: Text(
                text,
                style: TextStyle(color: !isSentMessage ? Colors.white : null),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
