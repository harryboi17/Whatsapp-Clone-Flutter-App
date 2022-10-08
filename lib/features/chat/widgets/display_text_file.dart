import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/widgets/video_player_item.dart';

import '../../../common/enums/message_enum.dart';

class DisplayTextFile extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final Color color;
  final double size;

  const DisplayTextFile({Key? key, required this.message, required this.type, required this.color, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    Duration progress = Duration.zero;
    Duration? total = Duration.zero;
    return type == MessageEnum.text
        ? Text(
            message,
            style: TextStyle(
              fontSize: size,
              color: color
            ),
          )
        : type == MessageEnum.audio
            ? StatefulBuilder(
              builder: (context, setState){
                audioPlayer.onPlayerComplete.listen((event) {
                  setState(() => isPlaying = false);
                });
                audioPlayer.onPositionChanged.listen((duration) {
                  setState(() => progress = duration);
                });
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        padding: const EdgeInsets.only(bottom: 9),
                        onPressed: () async {
                          if(isPlaying){
                            await audioPlayer.pause();
                            setState(() => isPlaying = false);
                          }else{
                            Duration? time = await audioPlayer.getCurrentPosition();
                            if(time == Duration.zero) {
                              await audioPlayer.play(UrlSource(message));
                              total = await audioPlayer.getDuration();
                            }else{
                              await audioPlayer.resume();
                            }
                            setState(() => isPlaying = true);
                          }
                        },
                        icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 30,),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6, left: 3),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width/2.5,
                        child: ProgressBar(
                          progress: progress,
                          total: total!,
                          onSeek: (duration){
                            audioPlayer.seek(duration);
                          },
                          thumbRadius: 8,
                        ),
                      ),
                    ),
                  ],
                );
              }
            )
            : type == MessageEnum.video
                ? VideoPlayerItem(videoUrl: message)
                : type == MessageEnum.gif
                    ? CachedNetworkImage(imageUrl: message)
                    : CachedNetworkImage(imageUrl: message);
  }
}
