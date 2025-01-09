import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/enums.dart';
import 'package:city_sightseeing/generated/assets.dart';
import 'package:city_sightseeing/model/sample_audio_model.dart';
import 'package:city_sightseeing/pages/audio/audio_map_screen.dart';
import 'package:city_sightseeing/pages/audio/language_select_screen.dart';
import 'package:city_sightseeing/service/provider/sample_audio_service.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:city_sightseeing/widgets/app_bar_audio.dart';
import 'package:city_sightseeing/widgets/audio_unavailable_widget.dart';
import 'package:city_sightseeing/widgets/audio_widget.dart';
import 'package:city_sightseeing/widgets/icon_text_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../screen/main_screen.dart';
import '../../service/provider/location_access_service.dart';
import '../../service/shared_pred_service.dart';
import '../../themedata.dart';
import '../../utils.dart';
import 'download_progress_dialgoue.dart';

class DownloadLanguageScreen extends StatefulWidget {
  bool? downloadedAudio;
  final String? pageId;

  DownloadLanguageScreen({this.downloadedAudio, this.pageId});

  @override
  State<DownloadLanguageScreen> createState() => _DownloadLanguageScreenState();
}

class _DownloadLanguageScreenState extends State<DownloadLanguageScreen> {
  ValueNotifier<bool> isAudioDownloaded = ValueNotifier(false);
  ValueNotifier<String> language = ValueNotifier("English");

  String img = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAudioData();
      if (widget.downloadedAudio != null) {
        setDownloadedTrue();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isError = Provider.of<SampleAudioService>(context).isError;
    String? audio = Provider.of<SampleAudioService>(context)
        .sampleAudioMessage
        ?.audio
        .audio;
    LandingPageData landingPageData = Provider.of<SampleAudioService>(context)
            .sampleAudioMessage
            ?.landingPageData ??
        LandingPageData();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarAudio(
          onLanguagePress: () async {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LanguageSelectScreen(pageId: widget.pageId,),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            color: Colors.white,
            child: !isError
                ? Column(children: [
                    Stack(
                      children: [
                        (landingPageData.image != null ||
                                (landingPageData.image?.isNotEmpty ?? false))
                            ? CachedNetworkImage(
                                height: 212,
                                imageUrl:
                                    '${ConstantStrings.base}${landingPageData.image.toString()}',
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  Assets.imagesDummyImage,
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                Assets.imagesDummyImage,
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              ),
                        Positioned(
                          left: 16,
                          bottom: 25,
                          child: Text(
                            landingPageData.title ?? ConstantStrings.hopOnOff,
                            style: TextStyle(
                                color: ThemeClass.whiteColor,
                                fontFamily: 'Lato',
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          detailIcons(landingPageData),
                          (audio == null || audio.isEmpty)
                              ? AudioUnavailableWiget()
                              : ValueListenableBuilder(
                                  valueListenable: language,
                                  builder: (BuildContext context, value,
                                      Widget? child) {
                                    return AudioWidget(
                                      page: ConstantStrings.sampleAudioPage,
                                      source:
                                          "${ConstantStrings.base}${audio.toString()}",
                                      language: language.value,
                                    );
                                  }),
                          ValueListenableBuilder(
                              valueListenable: isAudioDownloaded,
                              builder: (context, value, child) {
                                return !isAudioDownloaded.value
                                    ? TextButton(
                                        onPressed: () async {
                                          if (audio != null &&
                                              audio.isNotEmpty) {
                                            bool result =
                                                await _permissionRequest();
                                            if (result) {
                                              showDialog(
                                                context: context,
                                                builder: (dialogcontext) {
                                                  return DownloadProgressDialog(
                                                    baseUrl:
                                                        "${ConstantStrings.base}$audio",
                                                    fileName:
                                                        "sample-audio-${language.value}.mp3",
                                                  );
                                                },
                                              ).whenComplete(setDownloadedTrue);
                                            } else {
                                              print(
                                                  "No permission to read and write.");
                                            }
                                          } else {
                                            setDownloadedTrue();
                                          }
                                          await SharedPrefService()
                                              .setLanguageState(
                                                  LanguageState.downloaded);
                                        },
                                        style: TextButton.styleFrom(
                                          fixedSize: Size(295, 35),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 11, vertical: 7),
                                          backgroundColor: ThemeClass.redColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                        child: ValueListenableBuilder(
                                          valueListenable: language,
                                          builder: (BuildContext context,
                                              String value, Widget? child) {
                                            return Text(
                                                "Download ${language.value} Audio",
                                                style: TextStyle(
                                                  color: ThemeClass.whiteColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Lato',
                                                  height: 1.5,
                                                  fontSize: 15,
                                                ));
                                          },
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () {
                                          checkLocationPermission();
                                        },
                                        style: TextButton.styleFrom(
                                          fixedSize: Size(295, 35),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 11, vertical: 7),
                                          backgroundColor:
                                              ThemeClass.greenColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                        child: Text("Start Tour",
                                            style: TextStyle(
                                              color: ThemeClass.whiteColor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Lato',
                                              height: 1.5,
                                              fontSize: 15,
                                            )),
                                      );
                              }),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    LanguageSelectScreen(pageId: widget.pageId,)
                              ));
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(295, 35),
                              side: BorderSide(color: ThemeClass.redColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 7),
                              backgroundColor: ThemeClass.whiteColor,
                            ),
                            child: Text(
                              "Change audio language",
                              style: TextStyle(
                                color: ThemeClass.redColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lato',
                                height: 1.5,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            landingPageData.description ?? "",
                            style: TextStyle(
                              color: ThemeClass.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    )
                  ])
                : Column(children: [
                    Stack(
                      children: [
                        Image.asset(
                          Assets.imagesDummyImage,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          left: 16,
                          bottom: 25,
                          child: Text(
                            ConstantStrings.hopOnOff,
                            style: TextStyle(
                                color: ThemeClass.whiteColor,
                                fontFamily: 'Lato',
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          detailIcons(landingPageData),
                          AudioUnavailableWiget(),
                          !isAudioDownloaded.value
                              ? TextButton(
                                  onPressed: () {
                                    isAudioDownloaded.value = true;
                                  },
                                  style: TextButton.styleFrom(
                                    fixedSize: Size(295, 35),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 7),
                                    backgroundColor: ThemeClass.redColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child:
                                      Text("Download ${language.value} Audio",
                                          style: TextStyle(
                                            color: ThemeClass.whiteColor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Lato',
                                            height: 1.5,
                                            fontSize: 15,
                                          )),
                                )
                              : TextButton(
                                  onPressed: () {
                                    checkLocationPermission();
                                  },
                                  style: TextButton.styleFrom(
                                    fixedSize: Size(295, 35),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 7),
                                    backgroundColor: ThemeClass.greenColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: Text("Start Tour",
                                      style: TextStyle(
                                        color: ThemeClass.whiteColor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Lato',
                                        height: 1.5,
                                        fontSize: 15,
                                      )),
                                ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          LanguageSelectScreen(pageId: widget.pageId,)));
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(295, 35),
                              side: BorderSide(color: ThemeClass.redColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 7),
                              backgroundColor: ThemeClass.whiteColor,
                            ),
                            child: Text(
                              "Change audio language",
                              style: TextStyle(
                                color: ThemeClass.redColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lato',
                                height: 1.5,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Consumer<SampleAudioService>(
                            builder: (BuildContext context,
                                SampleAudioService value, Widget? child) {
                              return Text(
                                value.sampleAudioMessage?.landingPageData
                                        .description ??
                                    "",
                                style: TextStyle(
                                  color: ThemeClass.blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ])),
      ),
    );
  }

  void setDownloadedTrue() {
    isAudioDownloaded.value = true;
  }

  Widget detailIcons(LandingPageData data) {
    return Row(
      children: [
        IconTextWidget(
          imageName: Assets.imagesIcDistance,
          text: "${data.routeLength ?? "7.5"} m",
        ),
        SizedBox(
          width: 20,
        ),
        IconTextWidget(
          imageName: Assets.imagesTimeIcon,
          text: "${data.routeTime ?? "2"} h",
        ),
        SizedBox(
          width: 20,
        ),
        IconTextWidget(
          imageName: Assets.imagesStopIcon,
          text: "${data.numberOfStops ?? "20"} stops",
        ),
      ],
    );
  }

  Future<void> getAudioData() async {
    isAudioDownloaded.value = false;
    language.value = await Utils.getLanguagePreferences();
    Provider.of<SampleAudioService>(context, listen: false)
      ..isLoading = true
      ..getSampleAudioData();
  }

  static Future<bool> _permissionRequest() async {
    PermissionStatus result;
    if (Platform.isAndroid) {
      final sdkInt = await DeviceInfoPlugin().androidInfo;
      // debugPrint("Version ${sdkInt.version}");
      // debugPrint("Version ${sdkInt.version.sdkInt}");
      // debugPrint("Version ${sdkInt.version.release}");
      if (sdkInt.version.sdkInt >= 33) {
        return true;
      }
      var status = await Permission.storage.status;
      // print("status ${status}");
      if (status.isGranted) {
        return true;
      } else {
        result = await Permission.storage.request();
        // print("result :- ${result}");
        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    } else if (Platform.isIOS) {
      var status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      } else {
        result = await Permission.storage.request();

        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  Future<void> checkLocationPermission() async {
    var currStatus =
        await Provider.of<LocationPermissionProvider>(context, listen: false)
            .getCurrentStatus();
    if (currStatus) {
      checkLocationEnabled();
    } else {
      bool allowed = await Utils.askLocationPermissionDialog(context);
      if (allowed) {
        requestLocationPermission();
      } else {
        backToMainPage();
      }
    }
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = PermissionStatus.denied;
    status =
        await Provider.of<LocationPermissionProvider>(context, listen: false)
            .getLocationStatus();
    if (status.isGranted) {
      checkLocationEnabled();
    } else {
      if (Platform.isIOS) {
        openAppSettings();
      }
      backToMainPage();
    }
  }

  Future<void> checkLocationEnabled() async {
    var enabled =
        await Provider.of<LocationPermissionProvider>(context, listen: false)
            .locationServiceEnabled();
    if (enabled) {
      await SharedPrefService().setLanguageState(LanguageState.startTour);
      Navigator.of(context)
        ..pop()
        ..pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AudioMapPage(pageId: widget.pageId,),
          ),
        );
    } else {
      if (mounted) {
        Utils.showLocationEnableDialog(context);
      }
    }
  }

  void backToMainPage() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => MainScreen()),
      ModalRoute.withName('/main'),
    );
  }
}
