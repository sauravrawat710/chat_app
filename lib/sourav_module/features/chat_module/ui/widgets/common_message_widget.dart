import 'package:agora_chat_module/sourav_module/features/chat_module/models/message_data_model.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonMessageWidget extends StatelessWidget {
  const CommonMessageWidget({super.key, required this.messageData});

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    switch (messageData.type) {
      case MessageType.TXT:
        return _buildTextWidget();
      case MessageType.IMAGE:
        return _buildImageWidget();
      case MessageType.FILE:
        return _buildFileWidget(context);
      case MessageType.CUSTOM:
        return _buildContactWidget();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!messageData.isSender)
          Text(
            '~ ${messageData.from}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Text(
          messageData.message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Column _buildImageWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!messageData.isSender) ...[
          Text(
            '~ ${messageData.from}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
          const SizedBox(height: 5),
        ],
        Image.network(messageData.imagePath!),
        const SizedBox(height: 8),
        Center(
          child: Text(
            messageData.message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }

  Widget _buildFileWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!messageData.isSender)
          Text(
            '~ ${messageData.from}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 5),
            Text(
              messageData.message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => context
                  .read<ChatViewModel>()
                  .downloadAttachments(messageData),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade600,
                radius: 17,
                child: CircleAvatar(
                  backgroundColor: messageData.isSender
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
        if (!messageData.isSender)
          Text(
            '~ ${messageData.from}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Column(
          children: [
            Text(
              messageData.contact?.name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 5),
            Text(
              messageData.contact?.number ?? '',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const Divider(color: Colors.white30),
            TextButton.icon(
              onPressed: () async {
                final url = 'tel:${messageData.contact!.number}';
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
