import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/custom_map_model.dart';
import 'package:city_sightseeing/model/places_list_model.dart';
import 'package:city_sightseeing/model/routes_lat_long_model.dart';
import 'package:city_sightseeing/model/routes_list_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/bottom_sheet_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';

class MapFullScreen extends StatefulWidget {
  MapFullScreen({Key? key}) : super(key: key);

  @override
  _MapFullScreenState createState() => _MapFullScreenState();
}

class _MapFullScreenState extends State<MapFullScreen>
    with WidgetsBindingObserver {
  String _customMapUrl = "";

  late GoogleMapController mapController;

  double? _originLatitude;
  double? _originLongitude;

  bool isMapLoading = false;

  Map<MarkerId, Marker> markers = {};
  bool isMap = true;
  @override
  void initState() {
    initDAta();
    super.initState();
  }

  toggleMap() {
    debugPrint("TOGGLE MAP $_customMapUrl $isMap");
    if (isMap == true) {
      if (_customMapUrl == "") {
        _getCustomMapData();
      }
    }
    setState(() {
      isMap = !isMap;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
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
    } catch (e) {
    } finally {
      setState(() {
        isMapLoading = false;
      });
    }
  }

  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinates2 = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  @override
  void dispose() {
    super.dispose();
    try {
      mapController.dispose();
    } catch (e) {}
  }

  initDAta() async {
    if (mounted) {
      setState(() {
        isMapLoading = true;
      });
    }

    await getRoutesList1("tour");

    if (mounted) {
      setState(() {
        isMapLoading = false;
      });
    }
    await getRoutesList1("fairmount_park_loop");
    await getRoutesLatLong1("tour", "red");
    await getRoutesLatLong1("fairmount_park_loop", "blue");
    getPlacesList();
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

  Future _addMarker(
      LatLng position, String id, BitmapDescriptor descriptor, int indexcompare,
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

        });
    markers[markerId] = marker;

    setState(() {});
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

    _addPolyLine(routes.first.id.toString(), color, isFrom);
  }

  _addPolyLine(id1, Color color, int isFrom) {
    PolylineId id = PolylineId(isFrom == 1 ? "line1" : "line2");
    Polyline polyline = Polyline(
        polylineId: id,
        visible: true,
        color: color,
        points: isFrom == 1 ? polylineCoordinates : polylineCoordinates2,
        width: 5);
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  Future getRoutesLatLong1(String perameter, String Color) async {
    try {
      var map = new Map<String, dynamic>();
      map['type'] = perameter;

      var response = await HttpService.httpPostWithoutToken("map_routs", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        RoutesLatLongListModel routes = RoutesLatLongListModel.fromJson(body);
        for(LatLongModel item in routes.data!){
        }
        if (routes.data != null && routes.data!.isNotEmpty) {
          _getPolyline(routes.data, Color == "red" ? Colors.red : Colors.blue,
              Color == "red" ? 1 : 2);
        }
      }
    } catch (e) {}
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
                  BitmapDescriptor.defaultMarker,
                  rout.color == "red"
                      ? 1
                      : rout.color == "blue"
                          ? 2
                          : 3,
                  data: rout);
              setState(() {
                i++;
              });
              if (_originLatitude == null) {
                _originLatitude = double.parse(rout.latitude.toString());
                _originLongitude = double.parse(rout.longitude.toString());
              }
            }
          }
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "Map"),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 0,
          right: 0,
        ),
        height: height,
        width: width,
        child: _buildView(height),
      ),
    );
  }

  _buildView(height) {
    final transformationController = TransformationController();
    transformationController.toScene(Offset(0, 1));
    return Column(
      children: [
        Container(
          child: Column(
            children: [
              _buildMapButtonRow(),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        isMap
            ? isMapLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(_originLatitude.toString()),
                            double.parse(_originLongitude.toString())),
                        zoom: 15),
                    myLocationEnabled: true,
                    tiltGesturesEnabled: true,
                    compassEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    onMapCreated: _onMapCreated,
                    markers: Set<Marker>.of(markers.values),
                    polylines: Set<Polyline>.of(polylines.values),
                  ))
            : isMapLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 0.1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PhotoView(
                        minScale: PhotoViewComputedScale.covered,
                        initialScale: PhotoViewComputedScale.covered,
                        basePosition: Alignment(0, 0),
                        imageProvider: CachedNetworkImageProvider(
                          _customMapUrl,
                        ),
                      ),
                    ),
                  ),
      ],
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future _addMarkerforPlaces(LatLng position, String id,
      {required PlacesListData data}) async {
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
    // _icon = 'assets/images/stops/attraction1.png';
    final Uint8List markerIcon =
        await getBytesFromAsset(_icon, Platform.isIOS ? 90 : 80);

    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position,
        rotation: 2,
        onTap: () {
          _showBottomSheet(data);
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
}
