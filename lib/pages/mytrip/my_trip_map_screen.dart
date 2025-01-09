import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:ui' as ui;

import 'package:city_sightseeing/model/bus_track_model.dart';
import 'package:city_sightseeing/model/places_list_model.dart';
import 'package:city_sightseeing/model/routes_lat_long_model.dart';
import 'package:city_sightseeing/model/routes_list_model.dart';
import 'package:city_sightseeing/pages/map/stop_details_with_map.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

class MyTripMapScreen extends StatefulWidget {
  MyTripMapScreen({Key? key, required this.busCode}) : super(key: key);
  final String busCode;
  @override
  _MyTripMapScreenState createState() => _MyTripMapScreenState();
}

class _MyTripMapScreenState extends State<MyTripMapScreen>
    with WidgetsBindingObserver {
  // String _time = "";
  // String _remainingTime = "";
  // String _busNo = "";
  // late Completer<GoogleMapController> mapController;
  final mapController = Completer<GoogleMapController>();
  double? _originLatitude;
  double? _originLongitude;

  bool isMapLoading = true;
  Map<MarkerId, Marker> _busMarkers1 = {};
  List _tempbus0 = [];

  List _tempbus1 = [];

  int bus1currentindex = 0;

  int bus2currentindex = 0;

  Future _tempgetBus(dynamic _tempbus, bool isfirst) async {
    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/images/Bus_Icon-06.png', Platform.isIOS ? 50 : 50);
    var latlob;
    MarkerId markerId;
    if (isfirst) {
      latlob =
          LatLng(_tempbus[bus1currentindex][0], _tempbus[bus1currentindex][1]);
      markerId = MarkerId(_tempbus[bus1currentindex][2].toString());
    } else {
      latlob =
          LatLng(_tempbus[bus2currentindex][0], _tempbus[bus2currentindex][1]);
      markerId = MarkerId(_tempbus[bus2currentindex][2].toString());
    }
    // var latlob = LatLng(39.927431, -75.116094);

    Marker marker = Marker(
      markerId: markerId,
      // infoWindow: InfoWindow(
      //   title: "bus.title",
      // ),

      icon: BitmapDescriptor.fromBytes(markerIcon),
      position: latlob,
      rotation: 100,
      anchor: const Offset(0.5, 0.1),
    );
    setState(() {
      if (_busMarkers1.containsKey(markerId)) {
        _busMarkers1[markerId] = marker.copyWith(
            positionParam: LatLng(latlob.latitude, latlob.longitude));
        ;
      } else {
        _busMarkers1[markerId] = marker;
      }
    });
  }

  Map<MarkerId, Marker> markers = {};

  Map<MarkerId, Marker> _busMarkers = {};
  late Timer _timer;

  // void _onMapCreated(Completer<GoogleMapController> controller) async {
  //   mapController = controller;
  // }

  List<LatLng> polylineCoordinates = [];

  List<LatLng> polylineCoordinates2 = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  List _tempArrayList = [];
  @override
  void initState() {
    initDAta();
    super.initState();
  }

  initDAta() async {
    setState(() {
      isMapLoading = true;
    });

    await _getBusLocation();

    var cmsdata =
        Provider.of<InitialDataService>(context, listen: false).globalCmsData;
    _timer = Timer.periodic(
        Duration(seconds: int.parse(cmsdata!.refressTime.toString())),
        // Duration(seconds: 5),
        (timer) async {
      await _getBusLocation();
    });

    setState(() {
      isMapLoading = false;
    });

    await getRoutesList1("tour");
    await getRoutesList1("fairmount_park_loop");
    await getRoutesLatLong1("tour", "red");
    await getRoutesLatLong1("fairmount_park_loop", "blue");

    getPlacesList();
  }

  Future _getBusLocation() async {
    // debugPrint("------tracking bus----");
    try {
      Map<String, String> queryParameters;

      queryParameters = {
        "ticket_number": "${widget.busCode}",
        "latitude": "",
        "longitude": "",
        "is_multiple": "1",
      };
      var response =
          await HttpService.httpPostWithoutToken("track-bus", queryParameters);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        BusTrackModel _busLocation = BusTrackModel.fromJson(body);

        if (_busLocation.status == "200" || _busLocation.status == 200) {
          if (_busLocation.data != null && _busLocation.data!.isNotEmpty) {
            if (_originLatitude == null) {
              setState(() {
                _originLatitude =
                    double.parse(_busLocation.data!.first.latitude.toString());
                _originLongitude =
                    double.parse(_busLocation.data!.first.longitude.toString());
              });
            }

            for (var bus in _busLocation.data!) {
              if (bus.isShow == "1") {
                // print("object ${bus.title}");
                await _addBusMarker(
                    LatLng(double.parse(bus.latitude.toString()),
                        double.parse(bus.longitude.toString())),
                    bus.deviceId.toString(),
                    bus);
              } else {
                try {
                  MarkerId markerId = MarkerId(bus.deviceId.toString());
                  setState(() {
                    _busMarkers1..remove(markerId);
                  });
                } catch (e) {
                  print("${e} --->1 ");
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("-------------> $e");
    }
  }

  // Future<List> _determinePosition() async {
  //   List temp = ["", ""];

  //   var position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   if (position != null) {
  //     if (position.latitude != null || position.latitude != null) {
  //       temp[0] = position.latitude.toString();
  //       temp[1] = position.longitude.toString();
  //       return temp;
  //     } else {
  //       return temp;
  //     }
  //   } else {
  //     return temp;
  //   }
  // }

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
        rotation: 0,
        onTap: () {
          Navigator.push(
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

  Future _addBusMarker(LatLng position, String id, BusTrackData bus) async {
    final Uint8List markerIcon = await getBytesFromAsset(
        bus.deviceType == "Bus"
            ? 'assets/images/Bus_Icon-06.png'
            : 'assets/images/Bus_Icon-06blue.png',
        Platform.isIOS ? 68 : 68);

    MarkerId markerId = MarkerId(id);
    // Marker marker = Marker(
    //   markerId: markerId,
    //   infoWindow: InfoWindow(
    //     title: bus.title,
    //   ),
    //   icon: BitmapDescriptor.fromBytes(markerIcon),
    //   position: position,
    //   rotation: 0.2,
    //   anchor: Offset(0.4, 0.4),
    // );

    Marker marker = Marker(
      markerId: markerId,
      infoWindow: InfoWindow(
        title: "${bus.title}",
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      position: position,
      rotation: 10,
      anchor: const Offset(0.5, 0.5),
    );

    if (_busMarkers1.containsKey(markerId)) {
      print("-----------1");
      setState(() {
        _busMarkers1[markerId] = marker.copyWith(
            positionParam: LatLng(position.latitude, position.longitude));
      });
    } else {
      print("-----------2");
      setState(() {
        _busMarkers1[markerId] = marker;
      });
    }
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

        if (routes.data != null && routes.data!.isNotEmpty) {
          if (Color == "red") {
            //   setState(() {
            //     _tempbus0 = routes.data!
            //         .map((e) => [
            //               double.parse(e.latitude.toString()),
            //               double.parse(e.longitude.toString()),
            //               "marker13"
            //             ])
            //         .toList();
            //   });
            // } else {
            //   setState(() {
            //     _tempbus1 = routes.data!
            //         .map((e) => [
            //               double.parse(e.latitude.toString()),
            //               double.parse(e.longitude.toString()),
            //               "marker134"
            //             ])
            //         .toList();
            //   });

            //   print("object =====================>0${_tempbus0}");
            //   print("object =====================>1${_tempbus1}");
            //   var _tempbus1123 = _tempbus1.reversed;
            //   setState(() {
            //     // _tempbus1 = [];
            //     _tempbus1 = _tempbus1123.toList();
            //   });
            // });
          }

          _getPolyline(
            routes.data,
            Color == "red" ? Colors.red : Colors.blue,
            Color == "red" ? 1 : 2,
          );
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
          if (_originLatitude == null) {
            setState(() {
              _originLatitude =
                  double.parse(routes.data!.first.latitude.toString());
              _originLongitude =
                  double.parse(routes.data!.first.longitude.toString());
            });
          }
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
  void dispose() {
    super.dispose();
    try {
      _timer.cancel();
      // mapController.dispose();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "My Trip"),
      ),
      body: Container(
        padding: EdgeInsets.only(
          // top: 15,
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
    return Column(
      children: [
        // _buildTitle(),
        isMapLoading
            ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Expanded(
                child: Animarker(
                mapId: mapController.future.then<int>((value) => value.mapId),
                // curve: Curves.ease,
                duration: Duration(milliseconds: 500),
                // useRotation: false,
                isActiveTrip: true,
                shouldAnimateCamera: false,
                markers: _busMarkers1.values.toSet(),
                child: Consumer<InitialDataService>(
                    builder: (context, initdataService, child) {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            double.parse(initdataService
                                .globalCmsData!.centerLatitude
                                .toString()),
                            double.parse(initdataService
                                .globalCmsData!.centerLongitude
                                .toString())),
                        zoom: 15),
                    myLocationEnabled: true,
                    tiltGesturesEnabled: true,
                    compassEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    onMapCreated: (gController) =>
                        mapController.complete(gController),
                    markers: Set<Marker>.of(markers.values),
                    polylines: Set<Polyline>.of(polylines.values),
                  );
                }),
              ))
      ],
    );
  }

  // Card _buildTitle() {
  //   return Card(
  //     // margin: EdgeInsets.only(bottom: 2),
  //     child: Container(
  //       padding: EdgeInsets.all(20),
  //       // height: 100,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Bus No.:"),
  //               SizedBox(
  //                 height: 2,
  //               ),
  //               Text(
  //                 _busNo,
  //                 style: TextStyle(color: ThemeClass.redColor, fontSize: 18),
  //               )
  //             ],
  //           ),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               Text(_time),
  //               SizedBox(
  //                 height: 2,
  //               ),
  //               Text(
  //                 _remainingTime,
  //                 style: TextStyle(color: ThemeClass.redColor, fontSize: 18),
  //               )
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position,
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

  String _convertToRemaingTime(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1 && diff.inDays <= 1) {
      return '${diff.inDays} Day ';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} Hr';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} Min';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} Sec';
    } else {
      return 'just now';
    }
  }
}
