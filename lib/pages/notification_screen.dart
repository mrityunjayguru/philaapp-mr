import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:city_sightseeing/model/notification_list_model.dart';
import 'package:city_sightseeing/pages/map/attraction_details_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<NotificationListModel> getNotification() async {
    var token = await SharedPrefService.getToken();
    try {
      Map<String, String> queryParameters = {
        // "offers": "$value",
        "token": token.toString(),
      };

      var response =
          await HttpService.httpPost("notifications", queryParameters);
      // debugPrint("response ====> ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        NotificationListModel places = NotificationListModel.fromJson(body);

        return places;
      } else {
        throw "internal server error";
      }
    } catch (e) {
      if (e is SocketException) {
        throw "Socket exception";
      } else if (e is TimeoutException) {
        throw "Time out exception";
      } else {
        throw e.toString();
      }
    }
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
        padding: EdgeInsets.only(top: 15, left: 20, right: 20),
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: getNotification(),
                  builder:
                      (context, AsyncSnapshot<NotificationListModel> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          if (snapshot.data!.data != null) {
                            if (snapshot.data!.data!.isNotEmpty) {
                              var list = snapshot.data!.data!;
                              return Column(
                                children:
                                    list.map((e) => _buildList(e)).toList(),
                              );
                            } else {
                              return Container(
                                // height: height,
                                child: _buildDataNotFound1("Data Not Found!"),
                              );
                            }
                          } else {
                            return Container(
                                // height: height,
                                child: _buildDataNotFound1("Data Not Found!"));
                          }
                        } else {
                          return _buildDataNotFound1("Data Not Found!");
                        }
                      } else if (snapshot.hasError) {
                        // return Center(child: Text(snapshot.error.toString()));
                        return _buildDataNotFound1(snapshot.error.toString());
                      } else {
                        return _buildDataNotFound1("Data Not Found!");
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Container _buildDataNotFound1(
    String text,
  ) {
    return Container(
        height: 700,
        color: Colors.transparent,
        child: Center(child: Text("$text")));
  }

  Widget _buildList(NotificationData data) {
    if (data.type.toString().toLowerCase() == "place") {
      return _buildImageListTile(data);
    } else {
      return _buildWithoutImageListTile(data);
    }
  }

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);
    List months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    if (diff.inDays >= 1 && diff.inDays <= 1) {
      return '${diff.inDays} day(s) ago';
    }
    if (diff.inDays >= 1) {
      var current_yr = input.year;
      var current_mon = input.month;

      return "${input.day} ${months[current_mon - 1]} ${current_yr} ";
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hour(s) ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute(s) ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} second(s) ago';
    } else {
      return 'just now';
    }
  }

  _buildWithoutImageListTile(NotificationData data) {
    // DateTime time1 = DateTime.parse("2022-01-20 20:18:04Z");
    DateTime time1 = DateTime.parse(data.dateTime.toString());
    var timeToDisplay = convertToAgo(time1);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10),
          // height: 140,
          child: Row(children: [
            Expanded(
                // flex: 4,
                child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        color: ThemeClass.redColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    data.message.toString(),
                    style: TextStyle(
                        fontSize: 14,
                        color: ThemeClass.blackColor.withOpacity(0.7),
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            )),
          ]),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            timeToDisplay,
            style: TextStyle(
                fontSize: 14,
                color: ThemeClass.blackColor.withOpacity(0.25),
                fontWeight: FontWeight.bold),
          ),
        ),
        Divider(
          thickness: 1,
          height: 25,
        )
      ],
    );
  }

  _buildImageListTile(NotificationData data) {
    DateTime time1 = DateTime.parse(data.dateTime.toString());
    var timeToDisplay = convertToAgo(time1);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                AttractionDetailScreen(placeid: data.typeId.toString()),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            // height: 140,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 120,
                      width: 140,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(data.image.toString()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeClass.redColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              data.message.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeClass.blackColor.withOpacity(0.7),
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      )),
                ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              timeToDisplay,
              style: TextStyle(
                  fontSize: 14,
                  color: ThemeClass.blackColor.withOpacity(0.25),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            thickness: 1,
            height: 25,
          )
        ],
      ),
    );
  }
}
