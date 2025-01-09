import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:city_sightseeing/widgets/audio_unavailable_widget.dart';
import 'package:city_sightseeing/widgets/control_audio_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/assets.dart';
import '../../strings.dart';
import '../../themedata.dart';
import '../../widgets/app_bar_audio.dart';
import '../../widgets/audio_widget.dart';
import 'language_select_screen.dart';

class PlayAudioScreen extends StatefulWidget {
  final String? pageId;

  PlayAudioScreen({this.pageId});

  @override
  State<PlayAudioScreen> createState() => _PlayAudioScreenState();
}

class _PlayAudioScreenState extends State<PlayAudioScreen> {
  @override
  Widget build(BuildContext context) {
    final audioData = Provider.of<AudioMapService>(context).audioData;
    final selectedIndex =
        Provider.of<AudioMapService>(context).selectedAudioIndex;
    final audioList = Provider.of<AudioMapService>(context).audioLists;
    final isLoading = Provider.of<AudioMapService>(context).isLoadingAudio;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarAudio(
          onLanguagePress: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LanguageSelectScreen(
                  pageId: widget.pageId,
                ),
              ),
            );
          },
        ),
      ),
      body: Stack(fit: StackFit.expand, children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 50),
            color: Colors.white,
            child: Column(
              children: [
                audioData?.image != null
                    ? CachedNetworkImage(
                        width: double.infinity,
                        height: 220,
                        imageUrl: "${ConstantStrings.base}${audioData?.image}",
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Color(0xFF220220),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Color(0xFF220220),
                        ),
                      ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        "${audioData?.title}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeClass.blackColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      audioData?.audio == null ||
                              (audioData?.audio?.isEmpty ?? true)
                          ? AudioUnavailableWiget()
                          : AudioWidget(
                              isInQueue: audioData?.isInQueue,
                              title: audioData?.title ?? "",
                              page: ConstantStrings.triggerPointPage,
                              source: audioData!.audio![0] == "/"
                                  ? '${ConstantStrings.base}${audioData.audio?.substring(1)}'
                                  : '${ConstantStrings.base}${audioData.audio}',
                            ),
                      SizedBox(height: 10),
                      Text(
                        "${audioData?.description ?? ""}",
                        style: TextStyle(
                          color: ThemeClass.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     selectedIndex > 0
                  //         ? TextButton(
                  //             onPressed: () {
                  //               Provider.of<AudioMapService>(context,
                  //                       listen: false)
                  //                   .getTriggerPointData("prev");
                  //             },
                  //             style: TextButton.styleFrom(
                  //                 padding: EdgeInsets.symmetric(
                  //                     horizontal: 11, vertical: 7),
                  //                 shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.zero,
                  //                 ),
                  //                 side: BorderSide.none),
                  //             child: Row(
                  //               children: [
                  //                 Icon(
                  //                   Icons.arrow_back_ios_new,
                  //                   color: ThemeClass.blackColor,
                  //                   size: 13,
                  //                 ),
                  //                 Text(" Previous",
                  //                     style: TextStyle(
                  //                       color: ThemeClass.blackColor,
                  //                       fontWeight: FontWeight.w300,
                  //                       fontFamily: 'Lato',
                  //                       height: 1.5,
                  //                       fontSize: 13,
                  //                     )),
                  //               ],
                  //             ),
                  //           )
                  //         : Container(width: 10),
                  //     selectedIndex < audioList.length - 1
                  //         ? TextButton(
                  //             onPressed: () {
                  //               Provider.of<AudioMapService>(context,
                  //                       listen: false)
                  //                   .getTriggerPointData("next");
                  //             },
                  //             style: TextButton.styleFrom(
                  //                 padding: EdgeInsets.symmetric(
                  //                     horizontal: 11, vertical: 7),
                  //                 shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.zero,
                  //                 ),
                  //                 side: BorderSide.none),
                  //             child: Row(
                  //               children: [
                  //                 Text("Next ",
                  //                     style: TextStyle(
                  //                       color: ThemeClass.blackColor,
                  //                       fontWeight: FontWeight.w300,
                  //                       fontFamily: 'Lato',
                  //                       height: 1.5,
                  //                       fontSize: 13,
                  //                     )),
                  //                 Icon(
                  //                   Icons.arrow_forward_ios,
                  //                   color: ThemeClass.blackColor,
                  //                   size: 13,
                  //                 ),
                  //               ],
                  //             ),
                  //           )
                  //         : Container(width: 10),
                  //   ],
                  // ),
                  // SizedBox(height: 15,),
                  ControlAudioWidget()
                ],
              ),
            )),
        if (isLoading)
          Positioned.fill(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black54.withOpacity(0.3),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          )
      ]),
    );
  }
}
