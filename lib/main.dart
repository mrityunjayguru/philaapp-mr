import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:city_sightseeing/background_service.dart';
import 'package:city_sightseeing/pages/map/attraction_details_screen.dart';
import 'package:city_sightseeing/pages/map/stop_details_with_map.dart';
import 'package:city_sightseeing/routes.dart';
import 'package:city_sightseeing/service/navigation_service.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:city_sightseeing/service/provider/favorite_service.dart';
import 'package:city_sightseeing/service/provider/general_info_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/service/provider/location_access_service.dart';
import 'package:city_sightseeing/service/provider/play_audio_service.dart';
import 'package:city_sightseeing/service/provider/sample_audio_service.dart';
import 'package:city_sightseeing/service/provider/tour_list_service.dart';
import 'package:city_sightseeing/service/provider/tour_list_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/audio_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

late final MyAudioHandler audioHandler;

late final Directory directory;

Future<void> logToFile(String message, {
  bool start = false,
  bool end = false,
}) async {
  // debugPrint("msg:- ${message}", wrapWidth: 1000);
  final file = File('${directory.path}/app_log.txt');
  final DateTime now = DateTime.now();
  // String timestamp =
  //     "${now.month}||${now.day}||${now.year}||${now.hour}:${now.minute}:${now.second}||${now.millisecond}";
  final timestamp = DateTime.now().toIso8601String();
  if (start) {
    file.writeAsString('===Start Here===\n', mode: FileMode.append);
  }
  await file.writeAsString('[$timestamp] $message\n', mode: FileMode.append);
  if (end) {
    file.writeAsString('===Ends Here===\n', mode: FileMode.append);
  }
}

Future<File> getLogFile() async {
  final filePath = '${directory.path}/app_log.txt';
  return File(filePath);
}

Future<void> clearLogFile() async {
  final filePath = '${directory.path}/app_log.txt';
  File(filePath).writeAsString("");
}

Future<String> readLogFile() async {
  final logFile = await getLogFile();
  if (await logFile.exists()) {
    return logFile.readAsString();
  } else {
    return "Log file not found.";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeService();
  directory = await getApplicationDocumentsDirectory();
  stopBackgroundService();

  var _messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  //
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.citysightseeingphila.citySightseeingapp.audio',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: false,
  //   androidResumeOnClick: false,
  // );

  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    showSimpleNotification(
      Text(event.notification!.title.toString()),
      // leading: NotificationBadge(totalNotifications: _totalNotifications),
      subtitle: Text(event.notification!.body.toString()),
      background: ThemeClass.blackColor,
      duration: Duration(seconds: 3),
    );
  });
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    try {
      if (event.data['type'].toString().toLowerCase() == "stop") {
        Navigator.push(
          navigationService.navigationKey.currentContext!,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                StopDetailsScreenWithMap(id: event.data['type_id']),
          ),
        );
      } else if (event.data['type'].toString().toLowerCase() == "place") {
        Navigator.push(
          navigationService.navigationKey.currentContext!,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                AttractionDetailScreen(placeid: event.data['type_id']),
          ),
        );
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  });
}

Future<void> _messageHandler(RemoteMessage message) async {}
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  const MyApp({Key? key}) : super(key: key);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      stopBackgroundService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeClass.themeData,
      initialRoute: Routes.splashRoute,
      routes: Routes.globalRoutes,
      navigatorKey: navigationService.navigationKey,
      builder: (context, mainChild) {
        print("Hello updated value");
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<InitialDataService>(
              create: (_) => InitialDataService(),
            ),
            ChangeNotifierProvider<FavoriteService>(
              create: (_) => FavoriteService(),
            ),
            ChangeNotifierProvider<GeneralInfoService>(
              create: (_) => GeneralInfoService(),
            ),
            ChangeNotifierProvider<LocationPermissionProvider>(
              create: (_) => LocationPermissionProvider(),
            ),
            ChangeNotifierProvider<AudioMapService>(
              create: (_) => AudioMapService(context),
            ),
            ChangeNotifierProxyProvider<AudioMapService, PlayAudioService>(
              create: (context) => PlayAudioService(context),
              update: (context, audioMapService, playAudioService) =>
              playAudioService!,
            ),
            ChangeNotifierProvider<TourListService>(
              create: (_) => TourListService(),
            ),
            ChangeNotifierProvider<SampleAudioService>(
              create: (_) => SampleAudioService(),
            ),
          ],
          builder: (context, child) {
            return Builder(builder: (context) {
              return mainChild!;
            },);
          },
          // child: Builder(
          //   builder: (context) {
          //     return child!;
          //   }
          // ),
        );
      },
      navigatorObservers: [PageObserver()],
    );
  }
}
