import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonMessageWidget extends StatefulWidget {
  const CommonMessageWidget({super.key, required this.messages});

  // final MessageData messageData;
  final Message messages;

  @override
  State<CommonMessageWidget> createState() => _CommonMessageWidgetState();
}

class _CommonMessageWidgetState extends State<CommonMessageWidget> {
  final String regexPattern = r"@\w+";
  late List<Match> matches = [];

  @override
  void initState() {
    matches = [];
    matches = RegExp(regexPattern).allMatches(widget.messages.text).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.messages.type) {
      case MessageType.TEXT:
        return _buildTextWidget();
      case MessageType.IMAGE:
        return _buildImageWidget();
      case MessageType.FILE:
        return _buildFileWidget();
      case MessageType.CONTACT:
        return _buildContactWidget();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextWidget() {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     if (!widget.messages.isSender)
    //       Text(
    //         '~ ${widget.messages.sentBy}',
    //         style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
    //       ),
    //     RichText(
    //       text: TextSpan(
    //         children: [
    //           for (var match in matches)
    //             TextSpan(
    //               text: "${match.group(0)} ", // The mentioned username.
    //               style: const TextStyle(
    //                 color: Colors.blue, // You can choose a different color.
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //           TextSpan(
    //             text: widget.messages.text.replaceAllMapped(
    //                 RegExp(regexPattern), (match) => ''), // Remove mentions.
    //             style: const TextStyle(color: Colors.white),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );

    final text = widget.messages.text;

    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white),
      );
    }

    final textWidgets = <Widget>[];
    int currentPosition = 0;

    for (final match in matches) {
      // Add regular text before the mention.
      final beforeMention = text.substring(currentPosition, match.start);
      textWidgets.add(Text(
        beforeMention,
        style: const TextStyle(color: Colors.white),
      ));

      // Add the mention with a different style.
      final mentionText = text.substring(match.start, match.end);
      textWidgets.add(Text(
        mentionText,
        style: const TextStyle(
          color: Colors.blue, // You can choose a different color.
          fontWeight: FontWeight.bold,
        ),
      ));

      currentPosition = match.end;
    }

    // Add any remaining text after the last mention.
    final remainingText = text.substring(currentPosition);
    textWidgets.add(Text(
      remainingText,
      style: const TextStyle(color: Colors.white),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.messages.isSender)
          Text(
            '~ ${widget.messages.sentBy}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Row(mainAxisSize: MainAxisSize.min, children: textWidgets),
      ],
    );
  }

  Column _buildImageWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.messages.isSender) ...[
          Text(
            '~ ${widget.messages.sentBy}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
          const SizedBox(height: 5),
        ],
        Image.network(widget.messages.imageUrl!),
        const SizedBox(height: 8),
        Center(
          child: Text(
            widget.messages.text,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }

  Widget _buildFileWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.messages.isSender)
          Text(
            '~ ${widget.messages.sentBy}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 5),
            Text(
              widget.messages.text,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => context
                  .read<ChatViewModel>()
                  .downloadAttachments(widget.messages),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade600,
                radius: 17,
                child: CircleAvatar(
                  backgroundColor: widget.messages.isSender
                      ? const Color(0XFF075E54)
                      : const Color.fromARGB(255, 80, 79, 79),
                  radius: 15,
                  child: Icon(
                    Icons.download,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.messages.isSender)
          Text(
            '~ ${widget.messages.sentBy}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Column(
          children: [
            Text(
              widget.messages.contactInfo?.fullName ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 5),
            Text(
              widget.messages.contactInfo?.phoneNumber?.number.toString() ?? '',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const Divider(color: Colors.white30),
            TextButton.icon(
              onPressed: () async {
                final url =
                    'tel:${widget.messages.contactInfo!.phoneNumber?.number}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  launchUrl(Uri.parse(url));
                }
              },
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
          ],
        ),
      ],
    );
  }
}
