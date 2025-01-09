import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:city_sightseeing/background_service.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:city_sightseeing/service/provider/play_audio_service.dart';

import 'package:city_sightseeing/strings.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../screen/main_screen.dart';
import '../../themedata.dart';
import '../../utils.dart';
import '../../widgets/app_bar_audio.dart';
import '../../widgets/control_audio_widget.dart';
import '../../widgets/map_audio_item.dart';
import 'language_select_screen.dart';

class AudioMapPage extends StatefulWidget {
  final String? pageId;

  const AudioMapPage({
    Key? key,
    this.pageId,
  }) : super(key: key);

  @override
  State<AudioMapPage> createState() => _AudioMapPageState();
}

class _AudioMapPageState extends State<AudioMapPage> {
  Timer? timer;

  // late StreamSubscription<Position> _positionStream;
  late StreamSubscription<Position> _positionStreamBus;
  DateTime? _lastProximityCheckTime;

  var missedBusProximity = 0;
  ValueNotifier<bool> showLogs = ValueNotifier(false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) async {
        if (widget.pageId == "1") {
          await Provider.of<AudioMapService>(context, listen: false)
              .getRoutesLatLong("red");
          await Future.delayed(Duration(milliseconds: 200));
          await Provider.of<AudioMapService>(context, listen: false)
              .getRoutesList(context);
          await Future.delayed(Duration(milliseconds: 200));
        }
        await Provider.of<AudioMapService>(context, listen: false)
            .getAudioData(context, pageId: widget.pageId);
        stopBackgroundService();
        await Future.delayed(Duration(milliseconds: 500));
        startBackgroundService();
        // backgroundGeoLocation();

        // bg.BackgroundGeolocation.ready(bg.Config(
        //     desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        //     distanceFilter: 0.0,
        //     stopOnTerminate: true,
        //     startOnBoot: false,
        //     debug: true,
        //     logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        // )).then((bg.State state) {
        //   if (!state.enabled) {
        //     ////
        //     // 3.  Start the plugin.
        //     //
        //     bg.BackgroundGeolocation.start();
        //   }
        // });

        Provider.of<AudioMapService>(context, listen: false)
            .startListeningBackgroundLocationStream(
            context, pageId: widget.pageId);

        timer = Timer.periodic(
          Duration(minutes: 5),
              (timer) async {
            await _checkBusProximity();
          },
        );
        // _positionStreamDeviceProximity =
        //     Geolocator.getPositionStream(locationSettings: locationSettings1)
        //         .listen((Position? position) {
        //       _checkBusProximity();
        //     });
      },
    );
    super.initState();
  }

  void backgroundGeoLocation() {
    // bg.BackgroundGeolocation.ready(bg.Config(
    //         desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
    //         distanceFilter: 10,
    //         stopOnTerminate: true,
    //         startOnBoot: false,
    //         debug: true,
    //         isMoving: true,
    //         logLevel: bg.Config.LOG_LEVEL_VERBOSE))
    //     .then((bg.State state) {
    //   if (!state.enabled) {
    //     ////
    //     // 3.  Start the plugin.
    //     //
    //     bg.BackgroundGeolocation.start();
    //   }
    // });
  }

  void _checkProximityWithThrottle(Position? position) {
    print("Called");

    final now = DateTime.now();
    if (_lastProximityCheckTime == null ||
        now.difference(_lastProximityCheckTime!) > Duration(seconds: 10)) {
      Provider.of<AudioMapService>(context, listen: false)
          .checkProximity(position, context, pageId: widget.pageId);
      _lastProximityCheckTime = now;
    }
  }

  Future<void> _checkBusProximity() async {
    bool isInProximity = true;
    isInProximity = await Provider.of<AudioMapService>(context, listen: false)
        .checkBusProximity(context);
    if (!isInProximity) {
      missedBusProximity += 1;
    } else {
      missedBusProximity = 0;
    }

    if (missedBusProximity >= 3) {
      timer?.cancel();
      timer = null;
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => MainScreen()),
        ModalRoute.withName('/main'),
      );
      Utils.showMessage("You are not in proximity of the bus", context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    stopBackgroundService();
    super.dispose();
  }

  var _initialCameraPos = CameraPosition(
    target: LatLng(39.95275, -75.149362),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    var markersTEMP = Provider
        .of<AudioMapService>(context)
        .markersTEMP;
    var markers = Provider
        .of<AudioMapService>(context)
        .markers;
    var audioData = Provider
        .of<AudioMapService>(context)
        .audioData;
    var polyLine = Provider
        .of<AudioMapService>(context)
        .polylines;
    var loader = Provider
        .of<AudioMapService>(context)
        .isLoading;
    var originLat =
        Provider
            .of<AudioMapService>(context)
            .originLatitude ?? "39.95275";
    var originLong =
        Provider
            .of<AudioMapService>(context)
            .originLongitude ?? "-75.149362";

    var triggerPointProximity =
        Provider
            .of<AudioMapService>(context)
            .inSideTriggerPointProximity;
    var triggerPointAngle =
        Provider
            .of<AudioMapService>(context)
            .inSideProximityAngle;
    _initialCameraPos = CameraPosition(
        target: LatLng(double.parse(originLat.toString()),
            double.parse(originLong.toString())),
        zoom: 15);

    return PopScope(
      canPop: !loader,
      onPopInvoked: (didPop) {
        if (didPop) {
          Provider.of<AudioMapService>(context, listen: false)
              .removeDegreeSubscription();
          Provider.of<PlayAudioService>(context, listen: false)
              .stopAudio(ConstantStrings.triggerPointPage);
          Provider.of<AudioMapService>(context, listen: false).stopService();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBarAudio(
            onLanguagePress: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      LanguageSelectScreen(
                        pageId: widget.pageId,
                      ),
                ),
              );
            },
          ),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
                GoogleMap(
                onMapCreated: onMapCreated,
                initialCameraPosition: _initialCameraPos,
                markers: Set.from(markers + markersTEMP),
                polylines: Set<Polyline>.of(polyLine.values),
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                // onTap: (argument) {
                //   print(
                //     argument.toString(),
                //   );
                // },
              ),
              if (audioData != null)
                Positioned(
                  bottom: 60,
                  child: MapAudioItem(
                    pageId: widget.pageId,
                    audioData: audioData,
                  ),
                ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ControlAudioWidget(),
                ),
              ),
              if (loader == true)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54.withOpacity(0.3),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                ),

              // if (triggerPointProximity.isNotEmpty)
              /*  Positioned(
                left: 0,
                right: 0,
                top: 50,
                child: Container(
                  color: Colors.black54,
                  child: Column(
                    children: [
                      Text(
                        "$triggerPointProximity",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "$triggerPointAngle",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      // ValueListenableBuilder<bool>(
                      //   valueListenable: showLogs,
                      //   builder: (context, log, child) {
                      //     if (log) {
                      //       return SizedBox(
                      //         height: 200,
                      //         child: SingleChildScrollView(
                      //           child: SelectableText(
                      //             "$logs",
                      //             style: TextStyle(
                      //                 fontSize: 20, color: Colors.white),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //     return SizedBox.shrink();
                      //   },
                      // )
                    ],
                  ),
                ),
              )*/
              /* Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.all(0),

                    icon: Icon(Icons.play_arrow,
                        color: ThemeClass.redColor, size: 50),
                    onPressed: () {
                      // debugPrint("widget.source ${widget.source}");
                      final source =
                      '${ConstantStrings
                          .base}uploads/sample_audio/1721726712_tera-ban-jaunga-ringtone-45467-45516.mp3'
                          .toString();

                      Provider.of<PlayAudioService>(context, listen: false)
                          .setPlayerSource(
                        source,
                        ConstantStrings.triggerPointPage,
                        isInQueue: "yes",
                        tag: MediaItem(
                          id: source,
                          title: "IN QUEUE",
                        ),
                      );

                      // provider.setPlayerSource(
                      //   Uri.parse(widget.source).toString(),
                      //   widget.page,
                      //   context,
                      // );
                    },
                  ),

                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.cancel,
                        color: ThemeClass.redColor, size: 50),
                    onPressed: () {
                      // debugPrint("widget.source ${widget.source}");
                      final source =
                      '${ConstantStrings
                          .base}uploads/sample_audio/1721125697_russian.mp3'
                          .toString();
                      Provider.of<PlayAudioService>(context, listen: false)
                          .setPlayerSource(
                        source,
                        ConstantStrings.triggerPointPage,
                        isInQueue: "no",
                        tag: MediaItem(
                          id: source,
                          title: "NOT IN QUEUE",
                        ),
                      );
                      // provider.setPlayerSource(
                      //   Uri.parse(widget.source).toString(),
                      //   widget.page,
                      //   context,
                      // );
                    },
                  )
                ],
              )*/
            ],
          ),
        ),
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    Provider.of<AudioMapService>(context, listen: false)
        .initializeMapController(controller);
  }
}
