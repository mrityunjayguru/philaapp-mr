import 'package:city_sightseeing/loading_screen.dart';
import 'package:city_sightseeing/pages/audio/download_language_screen.dart';
import 'package:city_sightseeing/pages/audio/language_select_screen.dart';
import 'package:city_sightseeing/pages/audio/play_audio_screen.dart';
import 'package:city_sightseeing/pages/map/map_full_screen.dart';

import 'package:city_sightseeing/pages/map/map_short_details_screen.dart';

import 'package:city_sightseeing/pages/mytrip/track_bus_screen.dart';
import 'package:city_sightseeing/pages/notification_screen.dart';
import 'package:city_sightseeing/pages/offers/offer_screen.dart';
import 'package:city_sightseeing/pages/route/route_screen.dart';
import 'package:city_sightseeing/pages/sidebar_pages/faqs_screen.dart';

import 'package:city_sightseeing/screen/overview_screen.dart';
import 'package:city_sightseeing/screen/main_screen.dart';
import 'package:city_sightseeing/screen/splash_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String mainRoute = "/main";
  static const String mainRouteforLoading = "/";

  static const String splashRoute = "/splash";
  static const String overViewScreen = "/overViewScreen";
  static const String notificationScreen = "/notificationScreen";

  static const String offerScreen = "/offerScreen";

  static const String trackBusScreen = "/trackBusScreen";

  static const String myTripMapScreen = "/myTripMapScreen";
  static const String routesScreen = "/routesScreen";
  static const String mapshortDetailsScreen = "/mapshortDetailsScreen";
  static const String mapFullScreen = "/mapFullScreen";
  static const String fAQsSCreen = "/fAQsSCreen";
  static const String selectLanguageScreen = "/selectLanguage";
  static const String downloadAudioScreen = "/downloadAudio";
  static const String playAudioScreen = "/playAudio";

  static Map<String, Widget Function(BuildContext)> globalRoutes = {
    mainRoute: (context) => MainScreen(),
    mainRouteforLoading: (context) => const LoadingScreen(),
    splashRoute: (context) => SplashScreen(),
    overViewScreen: (context) => OverViewScreen(),
    notificationScreen: (context) => NotificationScreen(),
    offerScreen: (context) => OfferScreen(),
    trackBusScreen: (context) => TrackBusScreen(),
    // myTripMapScreen: (context) => MyTripMapScreen(),
    routesScreen: (context) => RoutesScreen(),
    mapshortDetailsScreen: (context) => MapshortDetailsScreen(),
    fAQsSCreen: (context) => FAQsSCreen(),
    mapFullScreen: (context) => MapFullScreen(),
    selectLanguageScreen : (context) => LanguageSelectScreen(),
    downloadAudioScreen : (context) => DownloadLanguageScreen(),
    playAudioScreen : (context) => PlayAudioScreen()
  };
}
