import 'package:city_sightseeing/enums.dart';
import 'package:city_sightseeing/pages/audio/audio_map_screen.dart';
import 'package:city_sightseeing/pages/audio/download_language_screen.dart';
import 'package:city_sightseeing/pages/audio/language_select_screen.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:city_sightseeing/service/provider/play_audio_service.dart';
import 'package:city_sightseeing/service/provider/sample_audio_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioModuleWrapper extends StatelessWidget {
  final String? pageId;
  const AudioModuleWrapper({Key? key, required this.langState, this.pageId});

  final LanguageState langState;

  @override
  Widget build(BuildContext context) {
    return currentPage(context);
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider<AudioMapService>(
    //       create: (_) => AudioMapService(),
    //     ),
    //     ChangeNotifierProxyProvider<AudioMapService, PlayAudioService>(
    //       create: (context) => PlayAudioService(context),
    //       update: (context, audioMapService, playAudioService) =>
    //           playAudioService!,
    //     ),
    //     // ChangeNotifierProvider<PlayAudioService>(
    //     //   create: (_) => PlayAudioService(context),
    //     // ),
    //     ChangeNotifierProvider<SampleAudioService>(
    //       create: (_) => SampleAudioService(),
    //     ),
    //   ],
    //   child: Builder(
    //     builder: (context) {
    //       return currentPage(context);
    //     }
    //   ),
    // );
  }

  Widget currentPage(BuildContext context) {
    if (langState == LanguageState.startTour) {
      return AudioMapPage( pageId: pageId,);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute<void>(
      //     builder: (BuildContext context) => AudioMapPage(),
      //   ),
      // );
    } else if (langState == LanguageState.downloaded) {
      setData();
      return DownloadLanguageScreen(downloadedAudio: true, pageId: pageId,);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute<void>(
      //     builder: (BuildContext context) =>
      //         DownloadLanguageScreen(downloadedAudio: true),
      //   ),
      // );
    } else {
      return LanguageSelectScreen(fromPage: "home", pageId: pageId,);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute<void>(
      //     builder: (BuildContext context) => LanguageSelectScreen(
      //       fromPage: "home",
      //     ),
      //   ),
      // );
    }
  }

  void setData() async {
    await SharedPrefService().setLanguageState(LanguageState.downloaded);
    print("Done!");
  }
}
