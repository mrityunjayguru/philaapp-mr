import 'dart:io';

import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:dio/dio.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';

import 'generated/assets.dart';

class Utils {
  static Future<String> getLanguagePreferences() async {
    var lang = await SharedPrefService().getLanguage();
    return lang ?? "English";
  }

  static void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ThemeClass.redColor,
        behavior: SnackBarBehavior.floating,
        content: RichText(
          text: TextSpan(
            text: message,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  static Future<dynamic> askLocationPermissionDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Permissions",
                  style: TextStyle(
                      color: ThemeClass.redColor,
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                Container(
                  height: 1,
                  color: ThemeClass.redColor,
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  margin: EdgeInsets.only(bottom: 10),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  width: 60,
                  height: 60,
                  child: Image.asset(Assets.imagesLocationImg),
                ),
                Text(
                  "Allow Location Access",
                  style: TextStyle(
                      color: ThemeClass.blackColor,
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "We would like access to your location in order to show relevant information near you during your tour.",
                  style: TextStyle(
                      color: ThemeClass.blackColor,
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          backgroundColor: ThemeClass.redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text("Allow",
                            style: TextStyle(
                              color: ThemeClass.whiteColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              height: 1.5,
                              fontSize: 15,
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          backgroundColor: ThemeClass.redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text("Deny",
                            style: TextStyle(
                              color: ThemeClass.whiteColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              height: 1.5,
                              fontSize: 15,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> showLocationEnableDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Device Location",
                style: TextStyle(
                    color: ThemeClass.redColor,
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              Container(
                height: 1,
                color: ThemeClass.redColor,
                padding: EdgeInsets.only(top: 10, bottom: 20),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                width: 60,
                height: 60,
                child: Image.asset(Assets.imagesLocationImg),
              ),
              Text(
                "Please enable your device location to access the service",
                style: TextStyle(
                    color: ThemeClass.blackColor,
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    backgroundColor: ThemeClass.redColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text("Ok",
                      style: TextStyle(
                        color: ThemeClass.whiteColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        height: 1.5,
                        fontSize: 15,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FileDownload {
  Dio dio = Dio();
  bool isSuccess = false;

  void startDownloading(
    BuildContext context,
    final String baseUrl,
    final String fileName,
    final Function okCallback,
  ) async {
    String path = await _getFilePath(fileName);

    try {
      await dio.download(
        baseUrl,
        path,
        onReceiveProgress: (recivedBytes, totalBytes) {
          okCallback(recivedBytes, totalBytes);
        },
        deleteOnError: true,
      ).then((_) {
        isSuccess = true;
      });
    } catch (e) {
      Navigator.pop(context);
      print("Exception$e");
    }

    if (isSuccess) {
      Navigator.pop(context);
    }
  }

  Future<String> _getFilePath(String filename) async {
    Directory? dir;

    try {
      dir = await getDownloadDirectory();
      final folderName = 'city-sight-phila';
      dir = Directory('${dir.path}/${folderName}');
      if (await dir.exists() == false) {
        dir.create(recursive: true);
      }
      // if(await dir.exists()){
      //  final folderPath =  "${dir.path}";
      //
      //  dir = Directory(folderPath);
      //  if(!await dir.exists()){
      //    await dir.create(recursive: true);
      //  }
      // }
      // if (!await dir.exists() == true) await Directory(dir.path);

      // if (Platform.isIOS) {
      //   if (Platform.isIOS) {
      //     var tempDir = await getApplicationDocumentsDirectory();
      //     var tempDirPath = tempDir.path;
      //     final myAppPath = '$tempDirPath/my_app';
      //     dir = await Directory(myAppPath).create(recursive: true);
      //     // dir = await getApplicationDocumentsDirectory(); // for iOS
      //     // new Directory(dir.path+'/'+'dir').create(recursive: true)
      //     //     .then((Directory directory) {
      //     //   print('Path of New Dir: '+directory.path);
      //     // });
      //   } // for iOS
      // } else {
      //
      // }
    } catch (err) {
      print("Cannot get download folder path $err");
    }
    print("Created ${dir?.path}/$filename");
    return "${dir?.path}/$filename";
  }
}
