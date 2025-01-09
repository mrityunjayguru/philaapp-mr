import 'dart:convert';
import 'dart:math';

import 'package:city_sightseeing/model/Gps_validation.dart';
import 'package:city_sightseeing/model/cms_page_model.dart';
import 'package:city_sightseeing/model/language_list_model.dart';
import 'package:city_sightseeing/model/notification_list_model.dart';
import 'package:city_sightseeing/model/slider_and_stop_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/strings.dart';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../../model/vehicle_list_model.dart';
import '../../utils.dart';

double? minDistanceGlobal = 0.0;

class InitialDataService with ChangeNotifier {
  List<SliderForHome>? globalSlider = [];
  List<StopForHome>? globalStops = [];

  // ----------------------------  for notification ---------------------------- //
  bool isBusArrivalNotification = true;
  bool isOtherNotification = true;
  NotificationData? GlobalNotificationData;

  CmsPageData? globalCmsData;
  var _slider = false;

  bool get SliderData => _slider;

  List<LanguageModel> languagesList = [];
  List<Device> devices = [];

  String selectedlanguage = "";

  setBusArrivalNotification(bool value) async {
    // try {
    //   await SharedPrefService().setBusArrivalNotification(value);
    //   isBusArrivalNotification = value;
    // } catch (e) {
    //   isBusArrivalNotification = true;
    // }

    isBusArrivalNotification = value;
    notifyListeners();
  }

  setOtherNotification(bool value) async {
    // try {
    //   await SharedPrefService().setOtherNotification(value);
    //   isOtherNotification = value;
    // } catch (e) {
    //   isOtherNotification = true;
    // }
    isOtherNotification = value;
    notifyListeners();
  }

  Future<void> getBusArrivalNotification() async {
    // try {
    //   var data = await SharedPrefService().getBusArrivalNotification();

    //   if (data != null) {
    //     isBusArrivalNotification = data;
    //   } else {
    //     isBusArrivalNotification = true;
    //   }
    // } catch (e) {
    //   isBusArrivalNotification = true;
    // }
    notifyListeners();
  }

  Future<void> getOtherNotification() async {
    // try {
    //   var data = await SharedPrefService().getOtherNotification();
    //   if (data != null) {
    //     isOtherNotification = data;
    //   } else {
    //     isOtherNotification = true;
    //   }
    // } catch (e) {
    //   isOtherNotification = true;
    // }
    notifyListeners();
  }

  void setSliderData(value) {
    _slider = value;
    notifyListeners();
  }

  Future<void> getCmsPageData() async {
    try {
      var url = ConstantStrings.cmsData;
      var response = await HttpService.httpGetWithoutToken(url);
      // debugPrint("CMS DATA ${response.statusCode}");
      if (response.statusCode == 200) {
        CmsPageModel sliderAndStopsData =
            CmsPageModel.fromJson(jsonDecode(response.body));

        if (sliderAndStopsData.data != null) {
          globalCmsData = sliderAndStopsData.data!;
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getSliderAndStopsData() async {
    try {
      var url = ConstantStrings.dashboardData;
      var response = await HttpService.httpGetWithoutToken(url);
      // debugPrint("SLIDER DATA ${response.statusCode}");
      if (response.statusCode == 200) {
        SliderAndStopModel sliderAndStopsData =
            SliderAndStopModel.fromJson(jsonDecode(response.body));

        if (sliderAndStopsData.data != null) {
          if (sliderAndStopsData.data!.slider != null &&
              sliderAndStopsData.data!.slider!.isNotEmpty) {
            globalSlider = sliderAndStopsData.data!.slider;
          }

          if (sliderAndStopsData.data!.stops != null &&
              sliderAndStopsData.data!.stops!.isNotEmpty) {
            globalStops = sliderAndStopsData.data!.stops;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<void> getNotificationData() async {
  //   try {
  //     var url = ConstantStrings.notificationData;
  //     var response = await HttpService.httpGetWithoutToken(url);
  //
  //     if (response.statusCode == 200) {
  //       CmsPageModel sliderAndStopsData =
  //           CmsPageModel.fromJson(jsonDecode(response.body));
  //
  //       if (sliderAndStopsData.data != null) {
  //         globalCmsData = sliderAndStopsData.data!;
  //       }
  //
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  Future<void> getLanguageData({String? pageId}) async {
    try {
      var response = await HttpService.httpGetWithoutToken(
          ConstantStrings.languageListApi);

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['success'].toString() == "1" &&
            res['status'].toString() == "200") {
          var tempData = LanguageListModel.fromJson(res);
          languagesList = tempData.data ?? [];
          if(pageId!=null){
            languagesList = languagesList.where((element) => element.pageId==pageId,).toList();
          }
        }
      }
    } catch (e, st) {
      String errorMessage = e.toString();

      debugPrintStack(
          label: "Catch sample audio data $errorMessage", stackTrace: st);
    }

    notifyListeners();
  }

  Future<bool> getGpsValidation() async {
    try {
      var response = await HttpService.httpPostWithoutToken(
          ConstantStrings.getGpsValidation, {});
      print("resposne ${response.statusCode}");
      if (response.statusCode == 200) {
        // var res = jsonDecode(response.body);
        debugPrint("GPS RESPONSE ${response.body}");
        final data = GpsValidation.fromJson(jsonDecode(response.body)["data"]);
        return data.gpsEnabled == 0;
        // if (res['success'].toString() == "1" &&
        //     res['status'].toString() == "200") {
        //   var tempData = LanguageListModel.fromJson(res);
        //   languagesList=tempData.message??[];
        // }
      } else {
        return false;
      }
    } catch (e, st) {
      debugPrintStack(label: "GPS Validation", stackTrace: st);
      return false;
    }
  }

  Future<void> getVehicleList() async {
    try {
      var response =
          await HttpService.httpGetWithoutToken(ConstantStrings.vehicleListApi);

      if (response.statusCode == 200) {
        // var res = jsonDecode(response.body);
        debugPrint("VEHICLE LIst RESPONSE ${response.body}");
        devices = Device.fromJsonList(response.body.toString());
        // if (res['success'].toString() == "1" &&
        //     res['status'].toString() == "200") {
        //   var tempData = LanguageListModel.fromJson(res);
        //   languagesList=tempData.message??[];
        // }
      }
    } catch (e, st) {
      String errorMessage = e.toString();

      debugPrintStack(
          label: "Catch vehicle list data $errorMessage", stackTrace: st);
    }

    notifyListeners();
  }

  Future<void> getSelectedLanguage() async {
    selectedlanguage = await Utils.getLanguagePreferences();
    notifyListeners();
  }

  Future<bool> getBusListProximity() async {
    if (devices.isNotEmpty) {
      var position = await Geolocator.getCurrentPosition();
      double minDistance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              double.tryParse(devices[0].latitude ?? "0") ?? 0,
              double.tryParse(devices[0].longitude ?? "0") ?? 0)
          .abs();
      for (int i = 0; i < devices.length; i++) {
        double distanceInMeters = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                double.tryParse(devices[i].latitude ?? "0") ?? 0,
                double.tryParse(devices[i].longitude ?? "0") ?? 0)
            .abs();
        minDistance = min(minDistance, distanceInMeters);
      }
      debugPrint("MIN DISTANCE $minDistance");
      minDistanceGlobal = minDistance;

      /// 160 feet by default = 48.768 meters
      /// Round Up value
      if (minDistance < 49) {
        return true;
      }
    }
    return false;
  }
}
