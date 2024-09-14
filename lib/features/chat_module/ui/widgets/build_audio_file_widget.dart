import '../../models/messages.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class BuildAudioFileWidget extends StatefulWidget {
  const BuildAudioFileWidget({super.key, required this.message});

  final Message message;

  @override
  State<BuildAudioFileWidget> createState() => _BuildAudioFileWidgetState();
}

class _BuildAudioFileWidgetState extends State<BuildAudioFileWidget> {
  late final AudioPlayer player;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0XFF128C7E),
            child: Icon(
              Icons.headphones,
              color: Colors.white,
              size: 28,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    if (player.state == PlayerState.playing) {
                      await player.stop();
                    } else {
                      await player.play(UrlSource(widget.message.audioUrl!));
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    player.state == PlayerState.playing
                        ? Icons.stop
                        : Icons.play_arrow,
                    color: const Color(0XFF128C7E),
                    size: 40,
                  ),
                ),
                const Expanded(
                  child: LinearProgressIndicator(
                    color: Color(0XFF128C7E),
                    value: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
