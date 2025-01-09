import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/provider/play_audio_service.dart';
import '../strings.dart';
import '../themedata.dart';

class ControlAudioWidget extends StatefulWidget {
  @override
  State<ControlAudioWidget> createState() => _ControlAudioWidgetState();
}

class _ControlAudioWidgetState extends State<ControlAudioWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<PlayAudioService>(
          builder: (BuildContext context, PlayAudioService playAudioService,
              Widget? child) {
            return playAudioService.playerStatePlaying
                ? LinearProgressIndicator(
                    color: ThemeClass.yellowColor,
                    value: (playAudioService.position != null &&
                            playAudioService.duration != null &&
                            playAudioService.position!.inMilliseconds > 0 &&
                            playAudioService.position!.inMilliseconds <
                                playAudioService.duration!.inMilliseconds)
                        ? playAudioService.position!.inSeconds /
                            playAudioService.duration!.inSeconds
                        : 0.0,
                  )
                : SizedBox();
          },
        ),
        Consumer<PlayAudioService>(
          builder: (BuildContext context, PlayAudioService playAudioService,
              Widget? child) {
            return playAudioService.playerStatePlaying
                ? GestureDetector(
                    onTap: () {
                      playAudioService.playerStatePlaying
                          ? playAudioService
                              .pauseAudio(ConstantStrings.triggerPointPage)
                          : playAudioService
                              .playAudio(ConstantStrings.triggerPointPage);
                    },
                    child: Container(
                      width: double.maxFinite,
                      height: 50,
                      color: ThemeClass.redColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: !playAudioService.playerStatePlaying
                          ? Icon(
                              Icons.play_arrow,
                              color: ThemeClass.whiteColor,
                            )
                          : Icon(
                              Icons.pause,
                              color: ThemeClass.whiteColor,
                            ),
                    ),
                  )
                : SizedBox();
          },
        ),
      ],
    );
  }
}
