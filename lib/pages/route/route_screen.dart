import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/routes_list_model.dart';
import 'package:city_sightseeing/pages/map/stop_details_with_map.dart';

import 'package:city_sightseeing/screen/image_view_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/general_widget.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutesScreen extends StatefulWidget {
  RoutesScreen({Key? key}) : super(key: key);

  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  bool isSelect = true;
  List<String> _perameterToPass = ["tour", "fairmount_park_loop"];

  int currentIndec = 1;

  Future<RoutesListModel> getRoutesList() async {
    try {
      Map<String, String> queryParameters = {
        "type": "${_perameterToPass[currentIndec - 1]}"
      };

      var response =
          await HttpService.httpPostWithoutToken("routs", queryParameters);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        RoutesListModel routes = RoutesListModel.fromJson(body);

        return routes;
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

  _openGoogleMap(String latitude, String longitude, String title) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      showSnackbarMessageGlobal("Could not open google map.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "Route"),
      ),
      body: Container(
        height: height,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButtonToggle(width),
            FutureBuilder(
                future: getRoutesList(),
                builder: (context, AsyncSnapshot<RoutesListModel> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        if (snapshot.data!.data != null &&
                            snapshot.data!.data!.isNotEmpty) {
                          return Expanded(
                            child: _buildListView(snapshot.data!.data),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(top: 300),
                            child: _buildDataNotFound("Data Not Found!"),
                          );
                        }
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 300),
                          child: _buildDataNotFound("Data Not Found!"),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: _buildDataNotFound(snapshot.error.toString()),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: _buildDataNotFound("Data Not Found!"),
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 300),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // return Text("data");
                }),
          ],
        ),
      ),
    );
  }

  var leftcount = 0;
  var rightcount = 0;
  GestureDetector _buildListView(List<RouteModel>? routesList) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0) {
          leftcount++;

          rightcount = 0;
          if (leftcount == 10) {
            if (!isSelect) {
              setState(() {
                isSelect = !isSelect;
                currentIndec = 1;
              });
            }
          }
        } else {
          rightcount++;

          leftcount = 0;
          if (rightcount == 10) {
            if (isSelect) {
              setState(() {
                isSelect = !isSelect;
                currentIndec = 2;
              });
            }
          }
        }
      },
      child: ListView.builder(
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
          itemCount: routesList!.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              child: TimelineTile(
                  alignment: TimelineAlign.start,
                  isLast: index == routesList.length,
                  indicatorStyle: IndicatorStyle(
                    width: 40,
                    height: 40,
                    indicatorXY: 0,
                    indicator: routesList[index].color != null &&
                            routesList[index].color != "" &&
                            routesList[index].color!.toLowerCase() == "mix"
                        ? Stack(
                            children: [
                              Wrap(
                                direction: Axis.vertical,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: ThemeClass.redColor,
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: ThemeClass.skyblueColor,
                                    ),
                                  ),
                                ],
                              ),
                              Center(
                                child: Text(
                                  routesList[index].stopNo.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        : Container(
                            child: Center(
                              child: Text(
                                routesList[index].stopNo.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: routesList[index].color != null &&
                                      routesList[index].color != "" &&
                                      routesList[index].color!.toLowerCase() ==
                                          "blue"
                                  ? ThemeClass.skyblueColor
                                  : ThemeClass.redColor,
                            ),
                          ),
                  ),
                  afterLineStyle: LineStyle(
                    color: currentIndec == 1
                        ? ThemeClass.redColor
                        : ThemeClass.skyblueColor,
                    thickness: 1,
                  ),
                  beforeLineStyle: LineStyle(
                    color: currentIndec == 1
                        ? ThemeClass.redColor
                        : ThemeClass.skyblueColor,
                    thickness: 1,
                  ),
                  endChild: _buildImageTile(routesList[index])),
            );
          }),
    );
  }

  Center _buildDataNotFound(String text) {
    return Center(child: Text("$text"));
  }

  Container _buildImageTile(RouteModel routeData) {
    return Container(
      padding: EdgeInsets.only(bottom: 25, left: 5, right: 5, top: 0),
      child: Column(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                height: 147,
                imageUrl: '${routeData.image.toString()}',
                imageBuilder: (context, imageProvider) => Container(
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
                    Center(child: Icon(Icons.error)),
              ),
              InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: StopDetailsScreenWithMap(
                      id: routeData.id.toString(),
                    ),
                    withNavBar: false,
                    // withNavBar: true, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  height: 147,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.1, 0.5, 0.9],
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.all(10),
                  child: Text(routeData.title.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeClass.whiteColor,
                        fontSize: 18,
                      )),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, 30.0),
                  child: Row(
                    children: [
                      routeData.isStopImage.toString() == "1"
                          ? Container(
                              height: 60,
                              width: 60,
                              child: InkWell(
                                onTap: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: ImageViewScreen(
                                      title: routeData.description.toString(),
                                      image: routeData.stopImage.toString(),
                                    ),
                                    withNavBar: false,
                                    // withNavBar: true, // OPTIONAL VALUE. True by default.
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                                child: Container(
                                  // padding: EdgeInsets.all(200),
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(currentIndec == 1
                                          ? "assets/images/bus_rounded_white.png"
                                          : "assets/images/bus_rounded_blue.png"),
                                      // fit: BoxFit.contcain,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                      Container(
                        height: 60,
                        width: 60,
                        child: InkWell(
                          onTap: () {
                            _openGoogleMap(
                                routeData.latitude.toString(),
                                routeData.longitude.toString(),
                                routeData.title.toString());
                          },
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(currentIndec == 1
                                    ? "assets/images/location_round_icon.png"
                                    : "assets/images/location_rounded_blue.png"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Text(routeData.time.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: ThemeClass.redColor,
                    fontSize: 16,
                  )),
              height: 20,
            ),
          )
        ],
      ),
    );
  }

  Column _buildButtonToggle(double width) {
    return Column(
      children: [
        Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButtonblue(
                  callBack: () {
                    if (!isSelect) {
                      setState(() {
                        isSelect = !isSelect;
                        currentIndec = 1;
                      });
                    }
                  },
                  title: "Tour Route",
                  color: ThemeClass.redColor,
                  index: 1),
              SizedBox(
                width: 10,
              ),
              _buildButtonblue(
                  callBack: () {
                    if (isSelect) {
                      setState(() {
                        isSelect = !isSelect;
                        currentIndec = 2;
                      });
                    }
                  },
                  title: "Fairmount Park Loop",
                  color: ThemeClass.skyblueColor,
                  index: 2),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              height: isSelect ? 3 : 0,
              width: width * 0.5,
              color: Colors.red,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              height: !isSelect ? 3 : 0,
              width: width * 0.5,
              color: Colors.blue,
            )
          ],
        ),
      ],
    );
  }

  bool isLoading = false;

  Container _buildButtonblue(
      {required String title,
      required Color color,
      required Function callBack,
      required int index}) {
    return Container(
      width: 164,
      child: MaterialButton(
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        shape: Border.all(
            color: index == 1 ? ThemeClass.redColor : ThemeClass.skyblueColor),
        minWidth: 164,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              // horizontal: 7,
              vertical: 10,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: currentIndec != index ? color : ThemeClass.whiteColor,
                fontSize: 13,
              ),
            ),
          ),
        ),
        color: currentIndec == index ? color : ThemeClass.whiteColor,
        onPressed: () {
          callBack();
        },
      ),
    );
  }
}
