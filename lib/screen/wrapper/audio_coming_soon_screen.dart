import 'dart:io';

import 'package:city_sightseeing/enums.dart';
import 'package:city_sightseeing/screen/wrapper/audio_module_wrapper.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/service/provider/location_access_service.dart';
import 'package:city_sightseeing/service/provider/play_audio_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../model/tour_list/Code.dart';

class AudioComingSoonScreen extends StatefulWidget {
  final String? pageId;
  final List<Code>? code;
  final bool codeDependency;
  const AudioComingSoonScreen({Key? key, this.pageId, this.code, required this.codeDependency}) : super(key: key);

  @override
  State<AudioComingSoonScreen> createState() => _AudioComingSoonScreenState();
}

class _AudioComingSoonScreenState extends State<AudioComingSoonScreen> {
  final TextEditingController _textController = TextEditingController();

  final searchOnChange = new BehaviorSubject<String>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void initState() {

    if(!widget.codeDependency){
      whenWriteCodeEnter();
    }
    else{
      searchOnChange
          .debounceTime(Duration(milliseconds: 500))
          .listen(listenQueryString);
    }
    super.initState();
  }

  void listenQueryString(String queryString) {
    if (widget.code?.map((e) => e.ticketNumber,).toList().contains(queryString) ?? true) {
      whenWriteCodeEnter();
      FocusScope.of(context).unfocus();
    } else {
      // Utils.showMessage("message", context);
    }
  }

  void whenWriteCodeEnter() async {
    isLoading.value = true;
    bool isLocationEnabled =
        await Provider.of<LocationPermissionProvider>(context, listen: false)
            .locationServiceEnabled();
    bool isLocationPermission =
        await Provider.of<LocationPermissionProvider>(context, listen: false)
            .getCurrentStatus();
    if (isLocationEnabled && isLocationPermission) {
      checkProximityOfDevice();
    } else {
      if (!isLocationEnabled) {
        isLoading.value = false;
        Utils.showLocationEnableDialog(context);
      } else {
        bool allowed = await Utils.askLocationPermissionDialog(context);
        if (allowed) {
          PermissionStatus status =
              await Provider.of<LocationPermissionProvider>(context,
                      listen: false)
                  .getLocationStatus();

          if (status.isGranted) {
            checkProximityOfDevice();
          } else {
            if (status.isPermanentlyDenied ||
                (Platform.isIOS && !status.isGranted)) {
              isLoading.value = false;
              Utils.showMessage(
                "Please allow location permission to access audio",
                context,
              );
              openAppSettings();
            }
          }
        } else {
          isLoading.value = false;
          Utils.showMessage(
              "Please allow location permission to access audio", context);
        }
      }
    }
  }

  void checkProximityOfDevice() async {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AudioModuleWrapper(
                langState: langState,
                pageId: widget.pageId,
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
  }

  void stopAllAudio() {
    Provider.of<AudioMapService>(context, listen: false)
        .removeSubscriptionAndOthers();
    Provider.of<AudioMapService>(context, listen: false).stopService();
    Provider.of<PlayAudioService>(context, listen: false)
        .releasePlayer("", context);
  }

  void _search(String queryString) {
    searchOnChange.add(queryString);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) => Stack(
        children: [
          if(widget.codeDependency)Scaffold(
            appBar: AppBar(
              backgroundColor: ThemeClass.redColor,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: ThemeClass.whiteColor,
                ),
              ),
              title: Text(
                'Audio',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Spacer(),
                  Text(
                    "Enter Code",
                    style: TextStyle(
                      color: ThemeClass.redColor,
                      fontFamily: 'Lato',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _textController,
                      onChanged: _search,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      scrollPadding: EdgeInsets.zero,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: ThemeClass.redColor,
                      style: new TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: ThemeClass.greyColor,
                      ),
                    ),
                  ),
                  // Spacer(),
                ],
              ),
            ),
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
        ],
      ),
    );
  }
}
