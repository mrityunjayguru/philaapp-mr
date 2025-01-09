import 'package:audio_service/audio_service.dart';
import 'package:city_sightseeing/service/provider/play_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/assets.dart';
import '../service/provider/audio_map_service.dart';
import '../strings.dart';
import '../themedata.dart';

class AudioWidget extends StatefulWidget {
  AudioWidget({
    Key? key,
    required this.page,
    required this.source,
    this.language,
    this.title, this.isInQueue,
  }) : super(key: key);

  final String page;
  final String source;
  final String? language, isInQueue;
  final String? title;

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  @override
  void initState() {
    super.initState();
    print(" SOURCE ==${widget.source}");
    // player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      Provider.of<PlayAudioService>(context, listen: false)
          .releasePlayer(widget.page, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPlay = false;
    if (widget.page == ConstantStrings.triggerPointPage) {
      var selectedIndex =
          Provider.of<AudioMapService>(context).selectedAudioIndex;
      if (selectedIndex != -1) {
        isPlay = Provider.of<AudioMapService>(context)
            .audioLists[selectedIndex]
            .play;
      }
    }
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
          color: ThemeClass.whiteColor,
          border: Border.all(color: ThemeClass.darkGreyColor),
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Row(
        children: [
          Container(
            height: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 16),
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: ThemeClass.yellowColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40)),
            ),
            child: Consumer<PlayAudioService>(builder: (BuildContext context,
                PlayAudioService provider, Widget? child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: ThemeClass.blackColor, shape: BoxShape.circle),
                    child: Image.asset(Assets.imagesHeadphoneImg),
                  ),
                  widget.page == ConstantStrings.triggerPointPage
                      ? (!isPlay
                          ? IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.play_arrow,
                                  color: ThemeClass.redColor, size: 50),
                              onPressed: () {
                                debugPrint("widget.source ${widget.source}");
                                Provider.of<AudioMapService>(context,
                                        listen: false)
                                    .checkProximityForTriggerPoint(context);
                                // provider.setPlayerSource(
                                //   Uri.parse(widget.source).toString(),
                                //   widget.page,
                                //   context,
                                // );
                              },
                            )
                          : IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.pause,
                                  color: ThemeClass.redColor, size: 50),
                              onPressed: () {
                                provider.pauseAudio(widget.page);
                              },
                            ))
                      : (!provider.playerStatePlayingSample
                          ? IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.play_arrow,
                                  color: ThemeClass.redColor, size: 50),
                              onPressed: () {
                                provider.setPlayerSource(
                                  Uri.parse(widget.source).toString(),
                                  widget.page,
                                  isInQueue: "no",
                                  tag: MediaItem(
                                    id: Uri.parse(widget.source).toString(),
                                    title: "${widget.title}",
                                  ),
                                );
                              },
                            )
                          : IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.pause,
                                  color: ThemeClass.redColor, size: 50),
                              onPressed: () {
                                provider.pauseAudio(widget.page);
                              },
                            ))
                ],
              );
            }),
          ),
          if (widget.page == ConstantStrings.sampleAudioPage)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Listen Sample",
                  style: TextStyle(
                      color: ThemeClass.blackColor,
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "(${widget.language})",
                  style: TextStyle(
                      color: ThemeClass.blackColor,
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                ),
              ],
            )
          else
            Expanded(
              child: Text(
                "${widget.title ?? ""} Audio Tour",
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: ThemeClass.blackColor,
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            )
        ],
      ),
    );
  }
}
