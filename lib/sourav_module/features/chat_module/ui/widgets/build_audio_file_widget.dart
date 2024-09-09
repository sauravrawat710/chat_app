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
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange[800],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.headphones,
                  color: Colors.white,
                ),
                FutureBuilder(
                  future: player.getDuration(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(
                        snapshot.data!.inMinutes.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                IconButton(
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
                    color: Colors.blueGrey,
                    size: 40,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    color: Colors.yellow[800],
                    value: 5,
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
