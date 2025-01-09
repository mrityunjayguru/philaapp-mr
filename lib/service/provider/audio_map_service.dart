import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:city_sightseeing/background_service.dart';
import 'package:city_sightseeing/generated/assets.dart';
import 'package:city_sightseeing/model/audio_map_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/provider/play_audio_service.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:city_sightseeing/widgets/map_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../enums.dart';
import '../../model/audio_view_model.dart';
import '../../model/routes_lat_long_model.dart';
import '../../model/routes_list_model.dart';
import '../../utils.dart';
import '../shared_pred_service.dart';
import 'dart:ui' as ui;

import 'initial_data_service.dart';

String logFile = "";

/// ==============================================================
///This is used for putting a log in the screen in debug mode|||
/// ==============================================================
Future<void> addDataToLog(
  String msg, {
  bool start = false,
  bool end = false,
}) async {
  // final DateTime now = DateTime.now();
  // String timeStamp =
  //     "${now.month}||${now.day}||${now.year}||${now.hour}:${now.minute}:${now.second}||${now.millisecond}";
  // final logFile = File('logfile.txt');
  //
  // // Prepare the log message
  // String logEntry = '';
  // if (start) logEntry += "====Starts Here====\n";
  // logEntry += "\\ ${timeStamp}:- $msg\\\n";
  // if (end) logEntry += "====Ends Here====\n";
  //
  // // Append the log entry to the file
  // await logFile.writeAsString(logEntry, mode: FileMode.append);
  // //remove
  //
}

class AudioMapService with ChangeNotifier {
  final BuildContext context;

  AudioMapService(this.context);

  List<AudioData> audioLists = [];
  bool isLoading = false;
  bool isLoadingAudio = false;
  bool isError = false;
  String errorMessage = "";
  List<Marker> markers = [];
  List<Marker> markersTEMP = [];
  bool isTrackingListening = false;

  Stream<Map<String, dynamic>?>? locationStream;

  // StreamSubscription<MagnetometerEvent>? deviceDegreeStream;
  StreamSubscription<CompassEvent>? deviceDegreeStream;

  var selectedAudioIndex = -1;
  AudioViewModel? audioData = null;

  BitmapDescriptor? selectedIcon;
  BitmapDescriptor? unSelectedIcon;

  int currentPriority = 0;

  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  int i = 111;
  double? originLatitude;
  double? originLongitude;
  GoogleMapController? mapController;
  String inSideTriggerPointProximity = "";
  String inSideProximityAngle = "";

  DateTime? subscriptionTime;

  void initializeMapController(GoogleMapController controller) {
    if (mapController != null) {
      mapController?.dispose();
      mapController = null;
    }
    mapController = controller;
  }

  void setMapController() {
    try {
      // debugPrint("selectedAudioIndex ${selectedAudioIndex}");
      if (audioLists.isNotEmpty) {
        mapController?.moveCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              double.tryParse(audioLists[selectedAudioIndex].latitude) ??
                  39.95275,
              double.tryParse(audioLists[selectedAudioIndex].longitude) ??
                  -75.149362,
            ),
            zoom: 17.2,
          )),
        );
      }
    } catch (e) {}
    notifyListeners();
  }

  void startService() {
    startBackgroundService();
  }

  void stopService() {
    stopBackgroundService();
  }

  Future setMarkerIcons() async {
    await getSelectedAudioIcon();
    await getUnselectedAudioIcon();
  }

  Future<void> getRoutesLatLong(String Color) async {
    try {
      isLoading = true;
      notifyListeners();
      var map = new Map<String, dynamic>();
      map['type'] = "tour";

      var response = await HttpService.httpPostWithoutToken("map_routs", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        RoutesLatLongListModel routes = RoutesLatLongListModel.fromJson(body);

        if (routes.data != null && routes.data!.isNotEmpty) {
          // _getPolyline(routes.data, Color == "red" ? Colors.red : Colors.blue,
          //     Color == "red" ? 1 : 2);
          _getPolyline(routes.data, Colors.red, 1);
        }
      }
    } catch (e) {}
  }

  Future<void> getRoutesList(context) async {
    try {
      var map = new Map<String, dynamic>();
      map['type'] = "tour";
      markers = [];
      var response = await HttpService.httpPostWithoutToken("routs", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        RoutesListModel routes = RoutesListModel.fromJson(body);

        if (routes.data != null && routes.data!.isNotEmpty) {
          // debugPrint(" LENGTh ${routes.data?.length}");
          for (var rout in routes.data!) {
            if (rout.latitude != "" &&
                rout.longitude != "" &&
                rout.longitude != null &&
                rout.latitude != "") {
              await _addMarker(
                  LatLng(double.parse(rout.latitude.toString()),
                      double.parse(rout.longitude.toString())),
                  i.toString(),
                  BitmapDescriptor.defaultMarker,
                  1,
                  data: rout);

              // await _addMarker(
              //     LatLng(double.parse(rout.latitude.toString()),
              //         double.parse(rout.longitude.toString())),
              //     i.toString(),
              //     BitmapDescriptor.defaultMarker,
              //     rout.color == "red"
              //         ? 1
              //         : rout.color == "blue"
              //         ? 2
              //         : 3,
              //     data: rout);
              i++;
              if (originLatitude == null) {
                originLatitude = double.parse(rout.latitude.toString());
                originLongitude = double.parse(rout.longitude.toString());
              }
            }
          }
        }
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> getAudioData(context, {String? pageId}) async {
    try {
      isLoading = true;
      isError = false;
      errorMessage = "";
      audioData = null;
      notifyListeners();
      selectedAudioIndex = -1;
      // await Future.delayed(Duration(seconds: 4));
      var response = await HttpService.httpPostWithoutToken(
        ConstantStrings.allTriggerPoint,
        null,
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        print("res $res");
        if (res['success'].toString() == "1" &&
            res['status'].toString() == "200") {
          var tempData = AudioMapModel.fromJson(res);
          audioLists = [];
          audioLists = tempData.data;
          if(pageId!=null){
            audioLists= audioLists.where((element) => element.pageId == pageId,).toList();
          }
          // audioLists=audioLists.where((data)=>data.showIcon== ShowIcon.YES).toList();
          // audioLists.sort((a, b) => a.priority?.compareTo(b.priority));
          isError = false;
          errorMessage = "";

          if (selectedIcon == null) {
            await setMarkerIcons();
          }
          _setMarkers(context,pageId: pageId);
          // int index =
          //     audioLists.indexWhere((data) => data.showIcon == ShowIcon.YES);
          // onTapAudioMarker(index);
          await getNearTriggerPoint(pageId: pageId);
        } else {
          isError = true;
          errorMessage = res['message'].toString();
        }
      } else if (response.statusCode == 401) {
        isError = true;
        errorMessage = "Internal Server Error.";
      } else {
        isError = true;
        errorMessage = "Something went wrong!";
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrintStack(label: "Catch getAudioData $e", stackTrace: st);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> getNearTriggerPoint( {String? pageId}) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (audioLists.isNotEmpty) {
        double minDistance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                double.tryParse(audioLists[0].latitude) ?? 0,
                double.tryParse(audioLists[0].longitude) ?? 0)
            .abs();
        AudioData selectedTriggerPoint = audioLists[0];
        int selectedIndex = 0;
        for (int i = 0; i < audioLists.length; i++) {
          double distanceInMeters = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  double.tryParse(audioLists[i].latitude) ?? 0,
                  double.tryParse(audioLists[i].longitude) ?? 0)
              .abs();
          if (distanceInMeters < minDistance) {
            selectedTriggerPoint = audioLists[i];
            selectedIndex = i;
            minDistance = distanceInMeters;
          }
        }
        await onTapAudioMarker(selectedIndex, pageId: pageId);
      }
    } catch (e) {}
  }

  Future<void> getTriggerPointData(String point, {String? pageId}) async {
    try {
      isLoadingAudio = true;
      isError = false;
      errorMessage = "";
      notifyListeners();
      String latitude = "";
      String longitude = "";
      if (point == "next") {
        if (selectedAudioIndex + 1 < audioLists.length) {
          int tempIndex = selectedAudioIndex + 1;
          latitude = audioLists[tempIndex].latitude;
          longitude = audioLists[tempIndex].longitude;
          onTapAudioMarker(tempIndex, pageId: pageId);
        }
      }
      if (point == "prev") {
        if (selectedAudioIndex - 1 >= 0) {
          int tempIndex = selectedAudioIndex - 1;
          latitude = audioLists[tempIndex].latitude;
          longitude = audioLists[tempIndex].longitude;
          onTapAudioMarker(tempIndex, pageId: pageId);
        }
      }
      if (point == "curr") {
        latitude = audioLists[selectedAudioIndex].latitude;
        longitude = audioLists[selectedAudioIndex].longitude;
      }

      var language = await SharedPrefService().getLanguageName();
      Map<String, String> queryParameters = {
        "languages": language.toString(),
        "latitude": latitude,
        "longitude": longitude,
        "page_id": pageId ?? ""
      };
      debugPrint(queryParameters.toString());
      var response = await HttpService.httpPostWithoutToken(
        ConstantStrings.getTriggerPoint,
        queryParameters,
      );

      if (response.statusCode == 200) {
        debugPrint("res ${response.body.toString()}");
        var res = jsonDecode(response.body);

        // print("res  $res");
        if (res['success'].toString() == "1" &&
            res['status'].toString() == "200") {
          var tempData = AudioViewModelList.fromJson(res);
          audioData = tempData.data;
          audioData?.showIcon = audioLists[selectedAudioIndex].showIcon;
          isError = false;
          errorMessage = "";
          notifyListeners();
        } else {
          isError = true;
          errorMessage = res['message'].toString();
        }
      } else if (response.statusCode == 401) {
        isError = true;
        errorMessage = "Internal Server Error.";
        print("Error 401");
      } else {
        isError = true;
        print("Error");
        errorMessage = "Something went wrong!";
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrintStack(label: "Catch getAudioData", stackTrace: st);
    }

    isLoadingAudio = false;
    notifyListeners();
  }

  /*
  * Markers logic
  * */

  Future<void> getSelectedAudioIcon() async {
    selectedIcon = await SvgPicture.asset(
      Assets.imagesSelectedMarkerAudio,
      height: 40,
      width: 40,
      fit: BoxFit.scaleDown,
    ).toBitmapDescriptor();
  }

  Future<void> getUnselectedAudioIcon() async {
    unSelectedIcon = await SvgPicture.asset(
      Assets.imagesUnselectedMarkerAudio,
      height: 40,
      width: 40,
      fit: BoxFit.scaleDown,
    ).toBitmapDescriptor();
  }

  void _setMarkers(context, {String? pageId}) {
    for (int i = 0; i < audioLists.length; i++) {
      var audioData = audioLists[i];
      markers.add(
        Marker(
          markerId: MarkerId("$i"),
          icon: unSelectedIcon!,
          visible: audioData.showIcon == ShowIcon.YES ? true : false,
          onTap: () {
            onTapAudioMarker(i, pageId: pageId);
          },
          position: LatLng(
            double.parse(audioData.latitude),
            double.parse(audioData.longitude),
          ),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> onTapAudioMarker(int index, {String? pageId}) async {
    if (audioLists.isNotEmpty) {
      if (selectedAudioIndex == index) {
        notifyListeners();
        return;
        // var temp_marker = markers[index];
        // markers[index] = temp_marker.copyWith(
        //   iconParam: unSelectedIcon,
        //   onTapParam: temp_marker.onTap,
        //   positionParam: temp_marker.position,
        // );
        // selectedAudio = -1;
        //
        // audioData = null;
      } else if (selectedAudioIndex == -1) {
        var temp_marker = markers[index];
        markers[index] = temp_marker.copyWith(
            iconParam: selectedIcon,
            onTapParam: temp_marker.onTap,
            positionParam: temp_marker.position);
        selectedAudioIndex = index;
        await getTriggerPointData("curr", pageId: pageId);
      } else {
        var temp_marker = markers[index];
        var previous_marker = markers[selectedAudioIndex];

        markers[selectedAudioIndex] = previous_marker.copyWith(
          iconParam: unSelectedIcon,
          onTapParam: previous_marker.onTap,
          positionParam: previous_marker.position,
        );

        markers[index] = temp_marker.copyWith(
          iconParam: selectedIcon,
          onTapParam: temp_marker.onTap,
          positionParam: temp_marker.position,
        );
        selectedAudioIndex = index;

        await getTriggerPointData("curr", pageId: pageId);
      }
      setMapController();
    }
    notifyListeners();
  }

  void setProximityAngleText(String text) {
    inSideProximityAngle = text;
    notifyListeners();
  }

  void setProximityTriggerText(String text) {
    inSideTriggerPointProximity = text;
    notifyListeners();
  }

  bool checkTime() {
    final now = DateTime.now();
    if (subscriptionTime == null) {
      subscriptionTime = now;
      return true;
    }

    if (now.difference(subscriptionTime!).inMilliseconds.abs() > 500) {
      subscriptionTime = now;
      return true;
    }
    return false;
  }

  void startListeningBackgroundLocationStream(BuildContext context, {String? pageId}) {
    // if (isTrackingListening) return;
    // isTrackingListening = true;
    locationStream = FlutterBackgroundService().on(updateLocation);
    locationStream?.listen(
      (event) async {
        debugPrint("Hello");
        if (!context.mounted) return;
        debugPrint("Hello double");
        final position = Position.fromMap(event!["position"]);
        await checkProximity(position, context, pageId: pageId);
      },
    );

    // bg.BackgroundGeolocation.onLocation((bg.Location location) async {
    //   print("========onLocation===========");
    //   print('[location] - $location');
    //   print("========onLocation===========");
    //   // await checkProximity(Position.fromMap(location.;toMap()), context);
    //   await checkProximityBGLocation(location, context);
    // });
  }

  /// to calculate the degree if devices changes the rotation!
  // double calculateHeading(MagnetometerEvent event) {
  //   double heading = atan2(event.x, event.y);
  //
  //   heading = heading * 180 / pi;
  //
  //   if (heading > 0) {
  //     heading -= 360;
  //   }
  //   // debugPrint("heading :- ${(heading * -1).roundToDouble()}");
  //   return (heading * -1).roundToDouble();
  // }

  double? calculateHeadingFlutterCompass(CompassEvent event) {
    return event.heading ?? 0.0;
  }

  /// to match the degree with the tolerance
  bool _isWithinTolerance(
    double? currentDegree,
    double? targetDegree,
    double? tolerance,
  ) {
    if (targetDegree == null) return true;
    if (tolerance == null) tolerance = 0.0;
    if (currentDegree == null) return true;

    // print("current degree : ${currentDegree!}");
    // print("target degree : ${targetDegree!}");
    // print("tolerence degree : ${tolerance!}");
    // print("1st condition  : ${(currentDegree! >= (targetDegree! - tolerance!))}");
    // print("2st condition  : ${currentDegree <= (targetDegree + tolerance)}");

    // Calculate the lower and upper bounds
    double lowerBound = targetDegree - tolerance;
    if (lowerBound < 0) {
      lowerBound += 360; // Adjust negative lower bound to positive
    }

    double upperBound = targetDegree + tolerance;
    if (upperBound >= 360) {
      upperBound -= 360; // Adjust upper bound if it exceeds 360
    }

    if (lowerBound > upperBound) {
      if (currentDegree < lowerBound) {
        return currentDegree <= upperBound;
      }
      return currentDegree >= lowerBound;
    }

    debugPrint("Degree :- $currentDegree -- ${lowerBound} -- ${upperBound}");

    return (currentDegree >= lowerBound && currentDegree <= upperBound);
  }

  void startCompassStreamListening() {
    if (deviceDegreeStream != null) return;
    deviceDegreeStream = FlutterCompass.events?.listen(
      (event) {},
      onError: (error) {},
      cancelOnError: true,
    );
  }

  void removeDegreeSubscription() {
    setProximityAngleText("Angle listening removed");
    deviceDegreeStream?.cancel();
    deviceDegreeStream = null;
    subscriptionTime = null;
  }

  // Future<void> showLogFile() async {
  //   // logFile = await readLogFile();
  //   notifyListeners();
  // }

  Future<void> checkProximity(Position? position, BuildContext context, {String? pageId}) async {
    // addDataToLog("Inside CheckProximity position:-$position");
    if (position != null && audioLists.isNotEmpty) {
      double minDistance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              double.tryParse(audioLists[0].latitude) ?? 0,
              double.tryParse(audioLists[0].longitude) ?? 0)
          .abs();
      AudioData selectedTriggerPoint = audioLists[0];
      int selectedIndex = 0;
      for (int i = 0; i < audioLists.length; i++) {
        double distanceInMeters = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                double.tryParse(audioLists[i].latitude) ?? 0,
                double.tryParse(audioLists[i].longitude) ?? 0)
            .abs();
        if (distanceInMeters < minDistance) {
          selectedTriggerPoint = audioLists[i];
          selectedIndex = i;
          minDistance = distanceInMeters;
        }
        // debugPrint(
        //     "DISTANCE BETWEEN POINTS $distanceInMeters PROXIMITY ${((audioLists[i].proximity ?? 0) / 3.281)}");
        // debugPrint("CURRENT POSITION ${position.latitude} ${position.longitude}");
        // debugPrint("TRIGGER POSITION ${double.tryParse(audioLists[i].latitude) ?? 0} ${double.tryParse(audioLists[i].longitude) ?? 0}  ");

        /// feet to meter conversion of proximity

        // if (distanceInMeters > ((audioLists[i].proximity ?? 0) / 3.281)) {
        //   if (audioLists[i].play) {
        //     // Provider.of<PlayAudioService>(context, listen: false)
        //     //     .stopAudio(ConstantStrings.triggerPointPage, context);
        //     // Utils.showMessage("You are out of proximity", context);
        //   }
        // }
      }

      // debugPrint("_________________________");
      // debugPrint(
      //     "_______$minDistance _____________${selectedTriggerPoint.proximity! / 3.281}");
      if (minDistance <= (selectedTriggerPoint.proximity ?? 0) / 3.281) {
        setProximityTriggerText(
          "You are inside the trigger point is the audio trigger is selected or not :- $minDistance",
        );

        ///TODO Check For --@demoPurpose
        // bool isDifIndex = false;
        // if (selectedAudioIndex != selectedIndex) {
        //   isDifIndex = true;
        //   addDataToLog("Different Index");
        //   addDataToLog(
        //     "Before Selected index :- $selectedAudioIndex || ${selectedIndex}",
        //   );
        //   addDataToLog(
        //     "Before audio name :- ${audioData?.audio}",
        //   );
        // } else {
        //   addDataToLog("Same Index $selectedIndex ${selectedAudioIndex}");
        // }

        await onTapAudioMarker(selectedIndex, pageId: pageId);
        // if (isDifIndex) {
        //   addDataToLog("After Selected index :- $selectedAudioIndex");
        //   addDataToLog("After audio name :- ${audioData?.audio}");
        // }

        if (audioData?.audio != null &&
            (audioData?.audio?.isNotEmpty ?? false)) {
          final audio = audioLists[selectedAudioIndex];
          if (!audio.autoPlayDone) {
            startCompassStreamListening();
          } else {
            removeDegreeSubscription();
          }
          deviceDegreeStream?.onData(
            (data) async {
              final check = checkTime();

              // addDataToLog("INSIDE ON DATA STREAM ${selectedAudioIndex} || ${selectedIndex}");
              if (!check) return;
              final heading = calculateHeadingFlutterCompass(data);
              bool isIN = _isWithinTolerance(
                heading,
                double.tryParse("${audio.angle}"),
                double.tryParse("${audio.tolerance}"),
              );

              if(audio.angle?.isEmpty ?? true){
                debugPrint("HELOOOO");
                setProximityAngleText("");
                setProximityTriggerText("");
                audioLists[selectedAudioIndex].autoPlayDone = true;
                removeDegreeSubscription();
                if (!audioLists[selectedAudioIndex].play) {
                  final source = Uri.parse(audioData!.audio![0] == "/"
                      ? '${ConstantStrings.base}${audioData?.audio?.substring(1)}'
                      : '${ConstantStrings.base}${audioData?.audio}')
                      .toString();

                  // addDataToLog("Source from our end :- ${audioData?.audio}");

                  await Provider.of<PlayAudioService>(context, listen: false)
                      .setPlayerSource(
                    source,
                    ConstantStrings.triggerPointPage,
                    isInQueue: audioData?.isInQueue,
                    tag: MediaItem(
                        id: source,
                        title: "${audioData?.title}",
                        displayTitle: "${audioData?.title}",
                        displaySubtitle: "${audioData?.description}"
                      // displaySubtitle:
                    ),
                  );
                }
              }
              else{
                if (isIN) {
                  setProximityAngleText(
                      "Now Audio should play you are right degree || current deg :- $heading||required angle :-${audio.angle}");
                  audioLists[selectedAudioIndex].autoPlayDone = true;
                  removeDegreeSubscription();

                  // addDataToLog("INSIDE ISIN ");

                  setProximityAngleText(
                      "Now Audio should play you are right degree || current deg :- $heading||required angle :-${audio.angle}");
                  if (!audioLists[selectedAudioIndex].play) {
                    final source = Uri.parse(audioData!.audio![0] == "/"
                        ? '${ConstantStrings.base}${audioData?.audio?.substring(1)}'
                        : '${ConstantStrings.base}${audioData?.audio}')
                        .toString();

                    // addDataToLog("Source from our end :- ${audioData?.audio}");

                    await Provider.of<PlayAudioService>(context, listen: false)
                        .setPlayerSource(
                      source,
                      ConstantStrings.triggerPointPage,
                      isInQueue: audioData?.isInQueue,
                      tag: MediaItem(
                          id: source,
                          title: "${audioData?.title}",
                          displayTitle: "${audioData?.title}",
                          displaySubtitle: "${audioData?.description}"
                        // displaySubtitle:
                      ),
                    );
                  }
                } else {
                  setProximityAngleText(
                      "Audio Closed Wrong degree || current degree $heading || required degree ${audioLists[selectedAudioIndex].angle}");
                  // if (audioLists[selectedAudioIndex].play) {
                  //   audioLists[selectedIndex].play = false;
                  //   await Provider.of<PlayAudioService>(context, listen: false)
                  //       .pauseAudio(
                  //     ConstantStrings.triggerPointPage,
                  //     // context,
                  //   );
                  // }
                }
              }


            },
          );
        } else {
          Utils.showMessage("Audio unavailable", context);
        }
      } else {
        setProximityTriggerText(
            "You are not inside the proximity of the nearest trigger point||Distance Remaining is:- $minDistance");
        removeDegreeSubscription();
        // Utils.showMessage(
        //     "You are not in proximity of the nearest trigger point", context);
      }
    }
    notifyListeners();
  }

  void setAudioListState(bool val) {
    if (audioLists.isNotEmpty) {
      if (audioLists.length>selectedAudioIndex && audioLists[selectedAudioIndex].play == val) return;
      for (AudioData item in audioLists) {
        item.play = false;
      }
      audioLists[selectedAudioIndex].play = val;
      notifyListeners();
    }
  }

  _getPolyline(List<LatLongModel>? routes, Color color, int isFrom) async {
    List<LatLongModel>? temproutes = [];
    routes!.forEach((element) {
      temproutes.add(element);
    });

    temproutes.removeWhere((element) {
      var indx = temproutes.indexOf(element);

      if (indx == 0 || indx == temproutes.length - 1) {
        return true;
      } else {
        return false;
      }
    });

    for (var point in routes) {
      if (isFrom == 1) {
        polylineCoordinates.add(LatLng(double.parse(point.latitude.toString()),
            double.parse(point.longitude.toString())));
      } else {
        // polylineCoordinates2.add(LatLng(double.parse(point.latitude.toString()),
        //     double.parse(point.longitude.toString())));
      }
    }

    _addPolyLine(routes.first.id.toString(), color, isFrom);
  }

  _addPolyLine(id1, Color color, int isFrom) {
    PolylineId id = PolylineId(isFrom == 1 ? "line1" : "line2");
    Polyline polyline = Polyline(
        polylineId: id,
        visible: true,
        color: color,
        // points: isFrom == 1 ? polylineCoordinates : polylineCoordinates2,
        points: polylineCoordinates,
        width: 5);
    polylines[id] = polyline;
  }

  Future _addMarker(
      LatLng position, String id, BitmapDescriptor descriptor, int indexcompare,
      {required RouteModel data}) async {
    Uint8List markerIcon;
    if (data.stopNo == "12") {
      if (data.color == "red") {
        markerIcon = await getBytesFromAsset(
            'assets/images/stops/red12.png', Platform.isIOS ? 90 : 120);
      } else {
        markerIcon = await getBytesFromAsset(
            'assets/images/stops/blue12.png', Platform.isIOS ? 90 : 120);
      }
    } else {
      markerIcon = await getBytesFromAsset(
          'assets/images/stops/red${data.stopNo.toString().trim()}.png',
          Platform.isIOS ? 90 : 120);
    }

    markersTEMP.add(
      Marker(
        markerId: MarkerId("RED MARKER$id"),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        onTap: () {},
        position: position,
      ),
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void checkProximityForTriggerPoint(BuildContext context) async {
    isLoadingAudio = true;
    notifyListeners();
    var position = await Geolocator.getCurrentPosition();
    double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        double.tryParse(audioLists[selectedAudioIndex].latitude ?? "0") ?? 0,
        double.tryParse(audioLists[selectedAudioIndex].longitude ?? "0") ?? 0);
    if (distance <= (audioLists[selectedAudioIndex].proximity ?? 0) / 3.281) {
      final source = Uri.parse(audioData!.audio![0] == "/"
              ? '${ConstantStrings.base}${audioData?.audio?.substring(1)}'
              : '${ConstantStrings.base}${audioData?.audio}')
          .toString();
      Provider.of<PlayAudioService>(context, listen: false).setPlayerSource(
        source,
        ConstantStrings.triggerPointPage,
        isInQueue: audioData?.isInQueue,
        tag: MediaItem(
          id: source,
          title: "${audioData?.title}",
        ),
      );
    } else {
      Utils.showMessage("You are out of proximity", context);
    }
    isLoadingAudio = false;
    notifyListeners();
  }

  Future<bool> checkBusProximity(context) async {
    var provider = Provider.of<InitialDataService>(context, listen: false);
    bool isInProximity = false;
    isInProximity = await provider.getGpsValidation();
    if (!isInProximity) {
      await provider.getVehicleList();
      isInProximity = await provider.getBusListProximity();
    }
    return isInProximity;
  }

  void removeSubscriptionAndOthers() {
    removeDegreeSubscription();
    stopService();
    // clearLogFile();
    logFile = "";
    // locationStream
    locationStream = null;
    // debugPrint("Removed Degree Subscription");
  }

  @override
  void dispose() {
    removeDegreeSubscription();
    stopService();
    super.dispose();
  }
}
