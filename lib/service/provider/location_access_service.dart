import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissions {
  granted,
  denied,
  restricted,
  permanentlyDenied,
}

class LocationPermissionProvider with ChangeNotifier {

  Future<PermissionStatus> getLocationStatus() async {

    var status = await Permission.location.request();

    if(status.isGranted){
      status = await Permission.locationAlways.request();
    }

    return status;

  }

  Future<bool> getCurrentStatus() async {

    var status = await Permission.location;
    if(await status.isGranted){
     status =  await Permission.locationAlways;
    }
    return status.isGranted;

  }

  Future<bool> locationServiceEnabled() async {
    bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
    return isLocationServiceEnabled;
  }

}
