import 'dart:convert';
import 'package:city_sightseeing/model/sample_audio_model.dart';
import 'package:city_sightseeing/model/tour_list/AudioTourListResponse.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:flutter/material.dart';

import '../../model/tour_list/TourData.dart';
import '../shared_pred_service.dart';

class TourListService with ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  String errorMessage="";
  List<TourData>  tourData =[];

  Future<void> getTourData() async {
    try {
      isLoading = true;
      isError = false;
      errorMessage = "";
      notifyListeners();
      var response = await HttpService.httpGetWithoutToken(ConstantStrings.getTourList);
      debugPrint("RES ${response.statusCode}");
      if (response.statusCode == 200) {

        var res = jsonDecode(response.body);
        if (res['success']) {
          var tempData = AudioTourListResponse.fromJson(res);
          debugPrint("RES ${tempData.data}");
          tourData=tempData.data ?? [];
          tourData = tourData.where((element) => element.status=="active",).toList();
          tourData.sort((a, b) {
            if (a.priority == null && b.priority == null) {
              return 0;
            } else if (a.priority == null) {
              return -1;
            } else if (b.priority == null) {
              return 1;
            }
            return a.priority!.compareTo(b.priority!);
          });
          isError = false;
          errorMessage = "";
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
    } catch (e,st) {
      errorMessage = e.toString();
      isError = true;
      debugPrintStack(label: "Catch sample audio data $errorMessage", stackTrace: st);
    }

    isLoading = false;
    notifyListeners();
  }

}
