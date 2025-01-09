import 'dart:convert';
import 'package:city_sightseeing/model/sample_audio_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:flutter/material.dart';

import '../shared_pred_service.dart';

class SampleAudioService with ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  String errorMessage="";
  SampleData? sampleAudioMessage;

  Future<void> getSampleAudioData() async {
    try {
      isLoading = true;
      isError = false;
      errorMessage = "";
      notifyListeners();
      var language = await SharedPrefService().getLanguageName();
      Map<String, String> queryParameters = {"languages": language.toString(), "page_id": "1"};
      var response = await HttpService.httpPostWithoutToken(ConstantStrings.sampleAudio, queryParameters);

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['success'].toString() == "1" &&
            res['status'].toString() == "200") {
          var tempData = SampleAudioModel.fromJson(res);
          debugPrint("RES ${tempData.data}");
         sampleAudioMessage=tempData.data;
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
