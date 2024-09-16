import 'package:chat_app/core/utlis/string_ext.dart';

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
          Text(
            text,
            style: TextStyle(
                color:
                    widget.messages.isSender ? null : const Color(0XFF010101)),
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
        style: TextStyle(
            color: widget.messages.isSender ? null : const Color(0XFF010101)),
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
      style: TextStyle(
          color: widget.messages.isSender ? null : const Color(0XFF010101)),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        style: const TextStyle(color: Color(0XFF128C7E)),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                widget.messages.text.overflow,
                style: TextStyle(
                  color: widget.messages.isSender
                      ? Colors.white
                      : const Color(0XFF010101),
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => context
                  .read<ChatViewModel>()
                  .downloadAttachments(widget.messages),
              child: CircleAvatar(
                backgroundColor: const Color(0XFF075E54).withOpacity(.9),
                radius: 17,
                child: const CircleAvatar(
                  backgroundColor: Color(0XFF075E54),
                  radius: 15,
                  child: Icon(
                    Icons.download,
                    color: Colors.white,
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
        Column(
          children: [
            Text(
              widget.messages.contactInfo?.fullName ?? '',
              style: TextStyle(
                color: widget.messages.isSender
                    ? Colors.white
                    : const Color(0XFF010101),
                fontSize: 12,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 5),
            Text(
              widget.messages.contactInfo?.phoneNumber?.number.toString() ?? '',
              style: TextStyle(
                color: widget.messages.isSender
                    ? Colors.white
                    : const Color(0XFF010101),
              ),
              textAlign: TextAlign.left,
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () async {
                final url =
                    'tel:${widget.messages.contactInfo!.phoneNumber?.number}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  launchUrl(Uri.parse(url));
                }
              },
              icon: const Icon(
                Icons.call,
                color: Color(0XFF128C7E),
              ),
              label: const Text('Call',
                  style: TextStyle(
                    color: Color(0XFF128C7E),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
