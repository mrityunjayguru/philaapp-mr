import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/custom_map_model.dart';
import 'package:city_sightseeing/model/places_list_model.dart';
import 'package:city_sightseeing/model/routes_lat_long_model.dart';
import 'package:city_sightseeing/model/routes_list_model.dart';
import 'package:city_sightseeing/model/stop_list_model.dart';
import 'package:city_sightseeing/pages/map/attraction_details_screen.dart';

import 'package:city_sightseeing/screen/image_view_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/bottom_sheet_widget.dart';
import 'package:city_sightseeing/widgets/general_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class StopDetailsScreenWithMap extends StatefulWidget {
  StopDetailsScreenWithMap({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  _StopDetailsScreenWithMapState createState() =>
      _StopDetailsScreenWithMapState();
}

class _StopDetailsScreenWithMapState extends State<StopDetailsScreenWithMap>
    with WidgetsBindingObserver {
  bool isMap = true;
  var _future;
  bool isMapLoading = false;
  late GoogleMapController mapController;

  late double _originLatitude;
  late double _originLongitude;
  String _customMapUrl = "";
  Map<MarkerId, Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  List<LatLng> polylineCoordinates = [];

  List<LatLng> polylineCoordinates2 = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    initDAta();
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
  void dispose() {
    try {
      mapController.dispose();
    } catch (e) {
      debugPrint(e.toString());
    }

    super.dispose();
  }

  initDAta() async {
    setState(() {
      isMapLoading = true;
    });
    _future = getStopDetailsList();
    await getRoutesList1("tour");
    await getRoutesList1("fairmount_park_loop");
    await getRoutesLatLong1("tour", "red");
    await getRoutesLatLong1("fairmount_park_loop", "blue");
    await getPlacesList();
    setState(() {
      isMapLoading = false;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future _addMarker(LatLng position, String id, int indexcompare,
      {required RouteModel data}) async {
    Uint8List markerIcon;
    if (data.stopNo == "12") {
      if (data.color == "red") {
        markerIcon = await getBytesFromAsset(
            'assets/images/stops/red12.png', Platform.isIOS ? 90 : 80);
      } else {
        markerIcon = await getBytesFromAsset(
            'assets/images/stops/blue12.png', Platform.isIOS ? 90 : 80);
      }
    } else {
      markerIcon = await getBytesFromAsset(
          'assets/images/stops/red${data.stopNo.toString().trim()}.png',
          Platform.isIOS ? 90 : 80);
    }

    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position,
        rotation: 2,
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  StopDetailsScreenWithMap(id: data.id.toString()),
            ),
          );
        });
    markers[markerId] = marker;
    setState(() {});
  }

  _showBottomSheet(PlacesListData data) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return BottomSheetforMapDetails(routesData: data);
        });
  }

  toggleMap() {
    if (isMap == true) {
      if (_customMapUrl == "") {
        _getCustomMapData();
      }
    }
    setState(() {
      isMap = !isMap;
    });
  }

  _getCustomMapData() async {
    setState(() {
      isMapLoading = true;
    });
    try {
      var response = await HttpService.httpGetWithoutToken("custom-map");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        CustomMapModel _busLocation = CustomMapModel.fromJson(body);

        if (_busLocation.status == "200" || _busLocation.status == 200) {
          if (_busLocation.data != null) {
            if (_customMapUrl == "") {
              setState(() {
                _customMapUrl = _busLocation.data!.image.toString();
              });
            }
          }
        }
      }
    } catch (e) {}
    setState(() {
      isMapLoading = false;
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   var height = MediaQuery.of(context).size.height;
  //   var width = MediaQuery.of(context).size.width;
  //   return Scaffold(
  //     // ignore: prefer_const_constructors
  //     appBar: PreferredSize(
  //       preferredSize: const Size.fromHeight(60),
  //       child: AppBarForMap(title: ""),
  //     ),
  //     body: Container(
  //       height: height,
  //       width: width,
  //       child: Column(
  //         children: [Text("data")],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: ""),
      ),
      body: Container(
        height: height,
        width: width,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            _buildMapButtonRow(),
            Expanded(
              child: FutureBuilder(
                  future: _future,
                  builder: (context, AsyncSnapshot<StopDetailModel> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          if (snapshot.data!.data != null) {
                            return _buildView(
                                height, width, snapshot.data!.data);
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
                        padding: const EdgeInsets.only(top: 0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Center _buildDataNotFound(String text) {
    return Center(child: Text("$text"));
  }

  Container _buildView(
      double height, double width, StopDetailsDataModel? stopDetails) {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 0, right: 0, bottom: 0),
      child: isMap
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildMapWithDetails(height, width, stopDetails))
          : isMapLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  // height: height - 175,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: PhotoView(
                    minScale: PhotoViewComputedScale.covered,
                    initialScale: PhotoViewComputedScale.covered,
                    // customSize: Size(MediaQuery.of(context).size.width,
                    //     MediaQuery.of(context).size.height - 165),
                    basePosition: Alignment(0, 0),
                    imageProvider: CachedNetworkImageProvider(
                      _customMapUrl,
                    ),
                  ),
                ),
    );
  }

  Column _buildMapWithDetails(
      double height, double width, StopDetailsDataModel? stopDetails) {
    return Column(
      children: [
        _buildMapView(height, width, stopDetails),
        _buildListtilecard(stopDetails),
        Transform.translate(
            offset: Offset(0, -33.0), child: _buildTwoIcon(stopDetails)),
        _buildBusTiming(stopDetails!.busTimings, stopDetails.color),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
              height: 30,
              thickness: 0.8,
              color: (stopDetails.color != null &&
                      stopDetails.color != "null" &&
                      stopDetails.color == "blue")
                  ? ThemeClass.skyblueColor
                  : ThemeClass.redColor),
        ),
        stopDetails.nearestPlaces != null &&
                stopDetails.nearestPlaces!.isNotEmpty
            ? _buildNearPlace(height, width, stopDetails.nearestPlaces)
            : SizedBox(),
        stopDetails.nearestLandmarks != null &&
                stopDetails.nearestLandmarks!.isNotEmpty
            ? _buildNearLandmark(height, width, stopDetails.nearestLandmarks)
            : SizedBox(),
      ],
    );
  }

  Column _buildNearLandmark(
      double height, double width, List<NearestLandMark>? nearplaces) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildHeartWithTitle(
            "assets/images/land_mark_icon.png", "  Nearest Landmarks"),
        SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: nearplaces!
                  .map((e) => _buildNearestCard(height, width, e))
                  .toList(),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Column _buildNearPlace(
      double height, double width, List<NearestPlace>? nearplaces) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildHeartWithTitle(
            "assets/images/favorite_icon.png", "  Nearest places to explore"),
        SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: nearplaces!
                  .map((e) => _buildNearestCard(height, width, e))
                  .toList(),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  InkWell _buildNearestCard(double height, double width, dynamic place) {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, Routes.mapLongDetailsScreen);
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: AttractionDetailScreen(placeid: place.id.toString()),
          withNavBar: false,
          // withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.2),
            blurRadius: 5.0, // soften the shadow
            spreadRadius: -7.0, //extend the shadow
            offset: Offset(
              -5.0, // Move to right 10  horizontally
              10.0, // Move to bottom 10 Vertically
            ),
          )
        ]),
        padding: EdgeInsets.only(right: 10),
        child: Card(
          child: Container(
            // padding: EdgeInsets.only(right: 10),
            color: Colors.white,
            height: 149,
            width: 175,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    // ignore: prefer_const_constructors
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(place.image.toString()),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        place.title.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ThemeClass.blackColor.withOpacity(0.8)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

// assets/images/favorite_icon.png
  Container _buildHeartWithTitle(String imagePath, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icon(Icons.ad_units),
          Container(
            // padding: EdgeInsets.all(200),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                // fit: BoxFit.contcain,
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: ThemeClass.blackColor,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }

  Column _buildBusTiming(List<BusTiming>? busTime, String? color) {
    return Column(
        children: busTime!
            .map((e) => Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildBusDetailsRow(e, busTime.indexOf(e), color),
                ))
            .toList());
  }

  Row _buildBusDetailsRow(BusTiming? busTiming, int index, color) {
    var title = "";
    var value = "";
    if (index == 0) {
      title = "First Bus";
      value = busTiming!.firstBus.toString();
    } else if (index == 1) {
      title = "Next Bus";
      value = busTiming!.nextBus.toString();
    } else if (index == 2) {
      title = "Last Bus";
      value = busTiming!.lastBus.toString();
    } else {
      title = "Frequency";
      value = busTiming!.Frequency.toString();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 7,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: index == 1
                      ? (color != null && color != "null" && color == "blue")
                          ? ThemeClass.skyblueColor
                          : ThemeClass.redColor
                      : ThemeClass.blackColor,
                  fontWeight: index == 1 ? FontWeight.w500 : FontWeight.w300),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 20,
          ),
        ),
        Expanded(
          flex: 7,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  color: index == 1
                      ? (color != null && color != "null" && color == "blue")
                          ? ThemeClass.skyblueColor
                          : ThemeClass.redColor
                      : ThemeClass.blackColor,
                  fontWeight: index == 1 ? FontWeight.w500 : FontWeight.w300),
            ),
          ),
        )
      ],
    );
  }

  Stack _buildListtilecard(StopDetailsDataModel? stopDetails) {
    return Stack(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                // contentPadding: EdgeInsets.zero,
                // minVerticalPadding: 0,
                title: Text(
                  stopDetails!.title.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                leading: stopDetails.color != null &&
                        stopDetails.color != "" &&
                        stopDetails.color!.toLowerCase() == "mix"
                    ? Container(
                        height: 40,
                        width: 40,
                        child: Stack(
                          children: [
                            Wrap(
                              direction: Axis.horizontal,
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
                                stopDetails.stopNo.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(
                        color: stopDetails.color != null &&
                                stopDetails.color != "" &&
                                stopDetails.color!.toLowerCase() == "red"
                            ? ThemeClass.redColor
                            : ThemeClass.skyblueColor,
                        height: 40,
                        width: 40,
                        child: Center(
                            child: Text(
                          stopDetails.stopNo.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ))),
                trailing: Text(
                  stopDetails.time.toString(),
                  style: TextStyle(
                      color: stopDetails.color != null &&
                              stopDetails.color != "" &&
                              stopDetails.color!.toLowerCase() == "red"
                          ? ThemeClass.redColor
                          : ThemeClass.skyblueColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 16),
                ),
              ),
              SizedBox(
                height: 25,
              )
            ],
          ),
        ),
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Positioned(
        //     child: Transform.translate(
        //         offset: Offset(0, 55.0), child: _buildTwoIcon(stopDetails)),
        //   ),
        // ),
      ],
    );
  }

  Row _buildTwoIcon(StopDetailsDataModel? stop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        stop!.isStopImage.toString() == "1"
            ? InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ImageViewScreen(
                      title: stop.description.toString(),
                      image: stop.stopImage.toString(),
                    ),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    // color: ThemeClass.redColor,
                    // borderRadius: BorderRadius.circular(30),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    // padding: EdgeInsets.all(200),
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage((stop.color != null &&
                                stop.color != "null" &&
                                stop.color == "blue")
                            ? "assets/images/bus_rounded_blue2.png"
                            : "assets/images/bus_icon.png"),
                        // fit: BoxFit.contcain,
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox(),
        // ignore: prefer_const_constructors
        stop.isStopImage.toString() == "1"
            ? SizedBox(
                width: 20,
              )
            : SizedBox(),
        InkWell(
          onTap: () {
            _openGoogleMap(stop.latitude.toString(), stop.longitude.toString(),
                stop.title.toString());
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage((stop.color != null &&
                          stop.color != "null" &&
                          stop.color == "blue")
                      ? "assets/images/location_rounded_blue2.png"
                      : "assets/images/location_red_rounded.png"),
                  // fit: BoxFit.contcain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container _buildMapView(
      double height, double width, StopDetailsDataModel? stopDetails) {
    return isMapLoading
        ? Container(
            height: height * 0.4,
            width: width,
            child: Center(
              child: CircularProgressIndicator(),
            ),
            decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(color: ThemeClass.redColor)),
            ),
          )
        : Container(
            height: height * 0.4,
            width: width,
            decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(color: ThemeClass.redColor)),
            ),
            child: GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                Factory<OneSequenceGestureRecognizer>(
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet(),
              initialCameraPosition: CameraPosition(
                  target: LatLng(_originLatitude, _originLongitude), zoom: 15),
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),
          );
  }

  Container _buildMapButtonRow() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            child: Text(
              'Map View',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              // primary: ThemeClass.redColor,
              backgroundColor:
                  isMap ? ThemeClass.yellowColor : ThemeClass.whiteColor,
              side: BorderSide(width: 0.5, color: ThemeClass.redColor),
            ).copyWith(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
            onPressed: () {
              if (!isMap) {
                toggleMap();
              }
            },
          ),
          SizedBox(
            width: 20,
          ),
          OutlinedButton(
            child: Text(
              'Tour Map',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ThemeClass.redColor),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              // primary: ThemeClass.redColor,
              backgroundColor:
                  !isMap ? ThemeClass.yellowColor : ThemeClass.whiteColor,
              side: BorderSide(width: 0.5, color: ThemeClass.redColor),
            ).copyWith(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
            onPressed: () {
              if (isMap) {
                toggleMap();
              }
            },
          )
        ],
      ),
    );
  }

  Future getRoutesLatLong1(String perameter, String Color) async {
    try {
      var map = new Map<String, dynamic>();
      map['type'] = perameter;

      var response = await HttpService.httpPostWithoutToken("map_routs", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        RoutesLatLongListModel routes = RoutesLatLongListModel.fromJson(body);

        if (routes.data != null && routes.data!.isNotEmpty) {
          _getPolyline(routes.data, Color == "red" ? Colors.red : Colors.blue,
              Color == "red" ? 1 : 2);
        }
      }
    } catch (e) {}
  }

  _getPolyline(List<LatLongModel>? routes, Color color, int isFrom) async {
    List<LatLongModel>? temproutes = [];
    routes!.forEach((element) {
      temproutes.add(element);
    });

    temproutes.removeWhere((element) {
      var indx = temproutes.indexOf(element);

      if (indx == 0 || indx == temproutes.length - 1) {
        return true;
      } else {
        return false;
      }
    });

    for (var point in routes) {
      if (isFrom == 1) {
        polylineCoordinates.add(LatLng(double.parse(point.latitude.toString()),
            double.parse(point.longitude.toString())));
      } else {
        polylineCoordinates2.add(LatLng(double.parse(point.latitude.toString()),
            double.parse(point.longitude.toString())));
      }
    }
    _addPolyLine(routes.first.latitude.toString(), color, isFrom);
  }

  _addPolyLine(id1, Color color, int isFrom) {
    PolylineId id = PolylineId(isFrom == 1 ? "line1" : "line2");
    Polyline polyline = Polyline(
        polylineId: id,
        color: color,
        points: isFrom == 1 ? polylineCoordinates : polylineCoordinates2,
        width: 5);
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  int i = 111;
  Future getRoutesList1(String perameter) async {
    try {
      var map = new Map<String, dynamic>();
      map['type'] = perameter;

      var response = await HttpService.httpPostWithoutToken("routs", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        RoutesListModel routes = RoutesListModel.fromJson(body);

        if (routes.data != null && routes.data!.isNotEmpty) {
          for (var rout in routes.data!) {
            if (rout.latitude != "" &&
                rout.longitude != "" &&
                rout.longitude != null &&
                rout.latitude != "") {
              await _addMarker(
                  LatLng(double.parse(rout.latitude.toString()),
                      double.parse(rout.longitude.toString())),
                  i.toString(),
                  rout.color == "red"
                      ? 1
                      : rout.color == "blue"
                          ? 2
                          : 3,
                  data: rout);
              setState(() {
                i++;
              });
            }
            // if (_originLatitude == null) {
            //   _originLatitude = double.parse(rout.latitude.toString());
            //   _originLongitude = double.parse(rout.longitude.toString());
            // }
          }
        }
      }
    } catch (e) {}
  }

  Future<StopDetailModel> getStopDetailsList() async {
    try {
      var response = await HttpService.httpGetWithoutToken("stop/${widget.id}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        StopDetailModel stop = StopDetailModel.fromJson(body);

        setState(() {
          // setCustomMarker();
          _originLatitude = double.parse(stop.data!.latitude.toString());
          _originLongitude = double.parse(stop.data!.longitude.toString());
        });
        return stop;
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

  Future<void> getPlacesList() async {
    try {
      Map<String, String> queryParameters = {"type": ""};

      var response =
          await HttpService.httpPostWithoutToken("places", queryParameters);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        PlacesListModel places = PlacesListModel.fromJson(body);

        if (places.data != null && places.data!.isNotEmpty) {
          for (var rout in places.data!) {
            if (rout.latitude.toString() != "" &&
                rout.longitude.toString() != "") {
              await _addMarkerforPlaces(
                LatLng(double.parse(rout.latitude.toString()),
                    double.parse(rout.longitude.toString())),
                i.toString(),
                data: rout,
              );
              setState(() {
                i++;
              });
            }
          }
        }
      }
    } catch (e) {}
  }

  Future _addMarkerforPlaces(LatLng position, String id,
      {required PlacesListData data}) async {
    // var customIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(size: Size(48, 48)),
    //     'assets/images/blak_circle2.png');

    var _icon = "";
    if (data.type == "shopping") {
      _icon = 'assets/images/stops/shopping.png';
    } else if (data.type == "attraction") {
      _icon = 'assets/images/stops/attraction.png';
    } else if (data.type == "dining") {
      _icon = 'assets/images/stops/dining.png';
    } else {
      _icon = 'assets/images/stops/thingsToDo.png';
    }
    final Uint8List markerIcon =
        await getBytesFromAsset(_icon, Platform.isIOS ? 90 : 80);

    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
        markerId: markerId,
        // icon: customIcon,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position,
        onTap: () {
          _showBottomSheet(data);
        });
    markers[markerId] = marker;

    setState(() {});
  }
}
