import '../../models/domain_user.dart';
import '../../models/messages.dart';
import 'build_audio_file_widget.dart';
import 'map_image_preview.dart';
import '../../view_model/chat_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonMessageWidget extends StatefulWidget {
  const CommonMessageWidget({super.key, required this.messages});

  final Message messages;

  @override
  State<CommonMessageWidget> createState() => _CommonMessageWidgetState();
}

class _CommonMessageWidgetState extends State<CommonMessageWidget> {
  final String regexPattern = r"@\w+";
  late List<Match> matches = [];
  late final ChatViewModel chatViewModel;
  DomainUser? senderUserInfo;

  @override
  void initState() {
    chatViewModel = context.read<ChatViewModel>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final member = context
        .watch<ChatViewModel>()
        .groupMembers
        .where((element) => element.id == widget.messages.sentBy)
        .toList();

    if (member.isNotEmpty) {
      senderUserInfo = member.first;
    }
    super.didChangeDependencies();
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
      case MessageType.AUDIO:
        return BuildAudioFileWidget(message: widget.messages);
      case MessageType.LOCATION:
        return MapImagePreview(locationData: widget.messages.location!);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextWidget() {
    final text = widget.messages.text;

    // Ensure that matches are updated when the widget is rebuilt.
    final matches = RegExp(regexPattern).allMatches(text);

    if (matches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.messages.isSender)
            Text(
              '~ ${senderUserInfo?.displayName}',
              style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
            ),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    final textWidgets = <Text>[];
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
      _checkValidMention(text, match, textWidgets, mentionText);
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
            '~ ${senderUserInfo?.displayName}',
            style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
          ),
        Row(mainAxisSize: MainAxisSize.min, children: textWidgets),
      ],
    );
  }

  void _checkValidMention(String text, RegExpMatch match,
      List<Text> textWidgets, String mentionText) {
    if (chatViewModel.groupMembers.any((element) =>
        element.displayName.toLowerCase() ==
        text.substring(match.start + 1, match.end).toLowerCase())) {
      textWidgets.add(Text(
        mentionText,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ));
    } else {
      textWidgets.add(Text(
        mentionText,
        style: const TextStyle(color: Colors.white),
      ));
    }
  }

  Widget _buildImageWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 190,
        width: 230,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: widget.messages.isSender
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (!widget.messages.isSender) ...[
              Text(
                '~ ${senderUserInfo?.displayName}',
                style: const TextStyle(fontSize: 12, color: Color(0XFFE1AD01)),
              ),
              const SizedBox(height: 5),
            ],
            Expanded(
              child: CachedNetworkImage(
                imageUrl: widget.messages.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.messages.isSender)
          Text(
            '~ ${senderUserInfo?.displayName}',
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
            '~ ${senderUserInfo?.displayName}',
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
