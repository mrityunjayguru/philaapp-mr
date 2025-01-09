import 'dart:async';
import 'dart:convert';

import 'package:city_sightseeing/model/general_info_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:flutter/cupertino.dart';

class GeneralInfoService with ChangeNotifier {
  GeneralInfoData? generalInfoData;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = "";
  Future<void> getGeneralInfo() async {
    isLoading = true;
    // notifyListeners();
    try {
      var response = await HttpService.httpGetWithoutToken(
        "get_general_info",
      );
      var res = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (res['success'].toString() == "1" &&
            res['status'].toString() == "200") {
          var TemporderData = GeneralInfoModel.fromJson(res);
          generalInfoData = TemporderData.data;

          isError = false;
          errorMessage = "";

          notifyListeners();
          return;
        } else {
          isError = true;
          errorMessage = res['message'].toString();
        }
      }
      else if (response.statusCode == 401) {
        isError = true;
        errorMessage = "Internal Server Error.";
      }
      else {
        isError = true;
        errorMessage = "Something went wrong!";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
