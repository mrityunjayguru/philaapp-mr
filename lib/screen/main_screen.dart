import 'dart:io';

import 'package:city_sightseeing/enums.dart';
import 'package:city_sightseeing/pages/home_page_screen.dart';
import 'package:city_sightseeing/pages/map/map_full_screen.dart';

import 'package:city_sightseeing/pages/mytrip/track_bus_screen.dart';
import 'package:city_sightseeing/pages/offers/offer_screen.dart';
import 'package:city_sightseeing/pages/route/route_screen.dart';
import 'package:city_sightseeing/screen/wrapper/audio_coming_soon_screen.dart';
import 'package:city_sightseeing/screen/wrapper/audio_module_wrapper.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/side_manu_widget.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../pages/audio/audio_tours_screen.dart';
import '../service/provider/location_access_service.dart';
import '../service/provider/play_audio_service.dart';
import '../utils.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  GlobalKey<ScaffoldState> _globalscafoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  void didPopNext() {
    print("Hello called here");
    stopAllAudio();
    super.didPopNext();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      // Provider.of<AudioMapService>(context, listen: false).setMarkerIcons();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    isLoading.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalscafoldKey,
        drawer: SideDrawerWidget(),
        extendBodyBehindAppBar: true,
        body: ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (BuildContext context, value, Widget? child) {
            return Stack(children: [
              PersistentTabView(
                context,
                onItemSelected: (item) {},
                navBarHeight: 66,
                screens: _buildScreens(),
                items: _navBarsItems(),
                backgroundColor: ThemeClass.redColor,
                stateManagement: true,
                hideNavigationBarWhenKeyboardShows: true,
                decoration: NavBarDecoration(
                  borderRadius: BorderRadius.circular(1.0),
                  colorBehindNavBar: Colors.white,
                ),
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,
                itemAnimationProperties: const ItemAnimationProperties(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: const ScreenTransitionAnimation(
                  animateTabTransition: true,
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 200),
                ),
                navBarStyle: NavBarStyle.style3,
              ),
              isLoading.value
                  ? Positioned.fill(
                      child: Container(
                      color: Colors.black54.withOpacity(0.3),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    ))
                  : SizedBox.shrink(),
            ]);
          },
        ));
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        onPressed: (ctx) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: RoutesScreen(), withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        activeColorPrimary: Colors.transparent,
        icon: Column(
          children: [
            Image.asset(
              "assets/images/routes_icon.png",
              height: 25,
              width: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Routes",
              style: TextStyle(color: ThemeClass.whiteColor.withOpacity(0.7)),
            )
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        onPressed: (ctx) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MapFullScreen(), withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        icon: Column(
          children: [
            Image.asset(
              "assets/images/map_icon.png",
              height: 25,
              width: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Map",
              style: TextStyle(color: ThemeClass.whiteColor.withOpacity(0.7)),
            )
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        onPressed: (ctx) async {

          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: AudioTourScreen(), withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
          // bool isLocationEnabled =
          //     await Provider.of<LocationPermissionProvider>(context,
          //             listen: false)
          //         .locationServiceEnabled();
          // bool isLocationPermission =
          //     await Provider.of<LocationPermissionProvider>(context,
          //             listen: false)
          //         .getCurrentStatus();
          // if (isLocationEnabled && isLocationPermission) {
          //   checkProximityOfDevice();
          // } else {
          //   if (!isLocationEnabled) {
          //     Utils.showLocationEnableDialog(context);
          //   } else {
          //     bool allowed = await Utils.askLocationPermissionDialog(context);
          //     if (allowed) {
          //       PermissionStatus status =
          //           await Provider.of<LocationPermissionProvider>(context,
          //                   listen: false)
          //               .getLocationStatus();
          //
          //       if (status.isGranted) {
          //         checkProximityOfDevice();
          //       } else {
          //         if (status.isPermanentlyDenied ||
          //             (Platform.isIOS && !status.isGranted)) {
          //           Utils.showMessage(
          //               "Please allow location permission to access audio",
          //               context);
          //           openAppSettings();
          //         }
          //       }
          //     } else {
          //       Utils.showMessage(
          //           "Please allow location permission to access audio",
          //           context);
          //     }
          //   }
          // }
        },
        icon: Column(
          children: [
            Image.asset(
              "assets/images/bottom_audio.png",
              height: 25,
              width: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Audio",
              style: TextStyle(color: ThemeClass.whiteColor.withOpacity(0.7)),
            )
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        onPressed: (context1) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: TrackBusScreen(), withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        icon: Column(
          children: [
            Image.asset(
              "assets/images/bottom_track.png",
              height: 25,
              width: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Track",
              style: TextStyle(color: ThemeClass.whiteColor.withOpacity(0.7)),
            )
          ],
        ),
        activeColorPrimary: Colors.transparent,
        activeColorSecondary: ThemeClass.redColor,
      ),
      PersistentBottomNavBarItem(
        onPressed: (context1) {
          var data = Provider.of<InitialDataService>(context, listen: false)
              .globalCmsData;
          debugPrint("DAta======> ${data?.ticketUrl}");
          if (data != null) {
            _launchURL(data.ticketUrl.toString());
          }
        },
        icon: Column(
          children: [
            Image.asset(
              "assets/images/ticket_icon.png",
              height: 25,
              width: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Tickets",
              style: TextStyle(color: ThemeClass.whiteColor.withOpacity(0.7)),
            )
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        onPressed: (context1) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: OfferScreen(), withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        icon: Column(
          children: [
            Image.asset(
              "assets/images/offer_icon.png",
              height: 25,
              width: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Offers",
              style: TextStyle(color: ThemeClass.whiteColor.withOpacity(0.7)),
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(scafoldkey: _globalscafoldKey),
      HomeScreen(scafoldkey: _globalscafoldKey),
      HomeScreen(scafoldkey: _globalscafoldKey),
      HomeScreen(scafoldkey: _globalscafoldKey),
      HomeScreen(scafoldkey: _globalscafoldKey),
      HomeScreen(scafoldkey: _globalscafoldKey)
    ];
  }

  void stopAllAudio() {
    Provider.of<AudioMapService>(context, listen: false)
        .removeSubscriptionAndOthers();
    Provider.of<AudioMapService>(context, listen: false).stopService();
    Provider.of<PlayAudioService>(context, listen: false)
        .releasePlayer("", context);
  }

/*  void checkProximityOfDevice() async {
    isLoading.value = true;
    var provider = Provider.of<InitialDataService>(context, listen: false);
    bool isInProximity = false;
    isInProximity = await provider.getGpsValidation();
    if (!isInProximity) {
      await provider.getVehicleList();
      isInProximity = await provider.getBusListProximity();
      Utils.showMessage("min distance :- ${minDistanceGlobal}", context);
    }

    if (isInProximity) {
      isLoading.value = false;
      LanguageState langState = await SharedPrefService().getLanguageState() ??
          LanguageState.noLangSelected;

      if (await Provider.of<LocationPermissionProvider>(context, listen: false)
              .getCurrentStatus() &&
          await Provider.of<LocationPermissionProvider>(context, listen: false)
              .locationServiceEnabled()) {
        if (await Provider.of<LocationPermissionProvider>(context,
                listen: false)
            .getCurrentStatus()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioModuleWrapper(
                langState: langState,
              ),
            ),
          ).whenComplete(
            () {
              stopAllAudio();
            },
          );
          // PersistentNavBarNavigator.pushNewScreen(
          //   context,
          //   screen: AudioModuleWrapper(
          //     langState: langState,
          //   ),
          //   withNavBar: false,
          //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
          // );
        } else {
          isLoading.value = false;
          Utils.showMessage("Please enable location permissions", context);
        }
      } else {
        isLoading.value = false;
        Utils.showMessage("Please enable location permissions", context);
      }
    } else {
      isLoading.value = false;
      Utils.showMessage("You are not in proximity of bus", context);
    }
  }*/
}
