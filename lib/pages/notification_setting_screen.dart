import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:city_sightseeing/model/get_notification_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/general_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class NotificationSettingScreen extends StatefulWidget {
  NotificationSettingScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool isLoading1 = false;
  bool isLoading2 = false;
  bool isLoading = false;
  @override
  void initState() {
    getNotification();
    super.initState();
  }

  Future getNotification() async {
    setState(() {
      isLoading = true;
    });

    try {
      var token = await SharedPrefService.getToken();
      Map<String, String> queryParameters = {"token": "$token"};

      var response = await HttpService.httpPostWithoutToken(
          "get_notification_settings", queryParameters);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        GetNotificationModel places = GetNotificationModel.fromJson(body);

        var pro = Provider.of<InitialDataService>(context, listen: false);

        pro.setBusArrivalNotification(
            places.data!.busArrivelNotification == "1");
        pro.setOtherNotification(places.data!.otherNotification == "1");
      } else {
        // throw "internal server error";
      }
    } catch (e) {
      if (e is SocketException) {
        debugPrint("socket exception screen :------ $e");

        // throw "Socket exception";
      } else if (e is TimeoutException) {
        debugPrint("time out exp :------ $e");

        // throw "Time out exception";
      } else {
        // debugPrint("home screen :------ $e");

        throw e.toString();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "Notifications"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 15, left: 15, right: 15),
        height: height,
        width: width,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(child: _buildView()),
      ),
    );
  }

  Column _buildView() {
    return Column(
      children: [
        _buildFirstRow(),
        SizedBox(
          height: 20,
        ),
        _buildSecondRow()
      ],
    );
  }

  ListTile _buildFirstRow() {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          "Bus arrival notification",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeClass.redColor),
        ),
      ),
      subtitle: Text(
        "You will be notified which bus is reaching at which stop and also which stop is about to reach.",
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ThemeClass.greyColor),
      ),
      trailing: isLoading1
          ? SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: ThemeClass.redColor,
                strokeWidth: 2,
              ),
            )
          : Container(
              height: 25,
              width: 50,
              child: Consumer<InitialDataService>(
                  builder: (context, initData, child) {
                return FlutterSwitch(
                  showOnOff: false,
                  inactiveColor: ThemeClass.greyColor.withOpacity(0.3),
                  activeColor: ThemeClass.redColor,
                  padding: 2,
                  value: initData.isBusArrivalNotification,
                  onToggle: (val) async {
                    setState(() {
                      isLoading1 = true;
                    });
                    var data = await _updateNotification(
                        true, initData.isBusArrivalNotification, val);

                    if (data != null && data == true) {
                      initData.setBusArrivalNotification(val);
                    }
                    setState(() {
                      isLoading1 = false;
                    });
                  },
                );
              }),
            ),
    );
  }

  ListTile _buildSecondRow() {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          "Other notification",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeClass.redColor),
        ),
      ),
      subtitle: Text(
        "You will be notified for offers, Route changes, Announcements, Etc.",
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ThemeClass.greyColor),
      ),
      trailing: isLoading2
          ? SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: ThemeClass.redColor,
                strokeWidth: 2,
              ),
            )
          : Container(
              height: 25,
              width: 50,
              child: Consumer<InitialDataService>(
                  builder: (context, initData, child) {
                return FlutterSwitch(
                  showOnOff: false,
                  inactiveColor: ThemeClass.greyColor.withOpacity(0.3),
                  activeColor: ThemeClass.redColor,
                  padding: 2,
                  value: initData.isOtherNotification,
                  onToggle: (val) async {
                    setState(() {
                      isLoading2 = true;
                    });
                    var data = await _updateNotification(
                        false, initData.isBusArrivalNotification, val);

                    if (data != null && data == true) {
                      initData.setOtherNotification(val);
                    }
                    setState(() {
                      isLoading2 = false;
                    });
                  },
                );
              }),
            ),
    );
  }

  Future _updateNotification(
      bool isBusNotificaion, bool compareValue, bool currentValue) async {
    var token = await SharedPrefService.getToken();

    Map<String, String> queryParameters = {};
    if (isBusNotificaion) {
      queryParameters = {
        "token": "$token",
        "bus_arrivel_notification": currentValue == true ? "1" : "0",
        "other_notification": compareValue == true ? "1" : "0",
      };
    } else {
      queryParameters = {
        "token": "$token",
        "bus_arrivel_notification": compareValue == true ? "1" : "0",
        "other_notification": currentValue == true ? "1" : "0"
      };
    }

    try {
      var response = await HttpService.httpPostWithoutToken(
          "update_notification_settings", queryParameters);

      if (response.statusCode == 200 || response.statusCode == "200") {
        final body = json.decode(response.body);
        if (body['status'] == 200 || body['status'] == "200") {
          // showSnackbarMessageGlobal(body['message'], context);
          return true;
        } else {
          showSnackbarMessageGlobal(body['message'], context);
        }
      } else {
        showSnackbarMessageGlobal("internal server error", context);
      }
    } catch (e) {
      if (e is SocketException) {
        debugPrint("socket exception screen :------ $e");

        showSnackbarMessageGlobal("Socket exception", context);
      } else if (e is TimeoutException) {
        debugPrint("time out exp :------ $e");
        showSnackbarMessageGlobal("Time out exception", context);
      } else {
        debugPrint("home screen :------ $e");
        showSnackbarMessageGlobal(e.toString(), context);
      }
    }
  }
}
