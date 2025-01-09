import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

final service = FlutterBackgroundService();

const stopStream = "stop-stream";
const updateLocation = "on-update-location";

bool? stoppedService;

void startBackgroundService() async {
  await service.startService();
  stoppedService = false;
}

void stopBackgroundService() async {
  if (await service.isRunning()) {
    // print("ISRUNNIG");
  }
  service.invoke(stopStream);
  service.invoke("stop");
  stoppedService = true;
}

Future<void> initializeService() async {
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: false,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance serviceInstance) async {
  DateTime? _lastProximityCheckTime;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );

  var _positionStream =
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
    print("on position changed");

    final now = DateTime.now();
    if (_lastProximityCheckTime == null ||
        now.difference(_lastProximityCheckTime!) > Duration(seconds: 4)) {
      print("on position invoked inside");
      final Map<String, dynamic>? args = {"position": position};
      serviceInstance.invoke(updateLocation, args);
      _lastProximityCheckTime = now;
    }
  }, onDone: () {
    print("On Done Called");
  });

  final streams = serviceInstance.on(stopStream);
  streams.listen(
    (event) {
      print("Service stopped");
      _positionStream.cancel();
      serviceInstance.stopSelf();
    },
  );
}
