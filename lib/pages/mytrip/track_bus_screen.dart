import 'dart:convert';

import 'package:city_sightseeing/model/bus_track_model.dart';
import 'package:city_sightseeing/pages/mytrip/my_trip_map_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/general_widget.dart';

import 'package:flutter/material.dart';

import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';

class TrackBusScreen extends StatefulWidget {
  TrackBusScreen({Key? key}) : super(key: key);

  @override
  _TrackBusScreenState createState() => _TrackBusScreenState();
}

class _TrackBusScreenState extends State<TrackBusScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool isFirstSubmit = true;

  @override
  void initState() {
    super.initState();
    getPreviousTicket();
  }

  Future getPreviousTicket() async {
    try {
      var ticket = await SharedPrefService().getPreviousTicket();

      setState(() {
        if (ticket.toString() != "null") {
          _textController.text = ticket.toString();
        }
      });
    } catch (e) {}
  }

  Future _getBusLocation() async {
    setState(() {
      _isLoading = true;
    });

    debugPrint("------tracking bus----");
    try {
      Map<String, String> queryParameters;
//       try {
//         var position = await _determinePosition();
//         queryParameters = {
//           "ticket_number": "${_textController.text}",
//           "latitude": position[0].toString(),
//           "longitude": position[1].toString(),
//           "is_multiple": "1",
//         };
//       } catch (e) {
//  queryParameters = {
//           "ticket_number": "${_textController.text}",
//           "latitude": "",
//           "longitude": "",
//           "is_multiple": "1",
//         };
//       }

      queryParameters = {
        "ticket_number": "${_textController.text}",
        "latitude": "",
        "longitude": "",
        "is_multiple": "1",
      };
      print(queryParameters);
      var response =
          await HttpService.httpPostWithoutToken("track-bus", queryParameters);
      debugPrint("bus track response ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);

        if (body['success'].toString() == "1" &&
            body['status'].toString() == "200") {

          BusTrackModel _busLocation = BusTrackModel.fromJson(body);

          if (_busLocation.status == "200" || _busLocation.status == 200) {
            if (_busLocation.data != null) {
              setState(() {
                _isLoading = false;
              });
              return true;
            } else {
              showSnackbarMessageGlobal(
                  _busLocation.data.toString(), context);
              return false;
            }
          } else {
            showSnackbarMessageGlobal(_busLocation.data.toString(), context);
            return false;
          }
        } else {
          showSnackbarMessageGlobal(body['data'].toString(), context);
          return false;
        }
      } else {
        showSnackbarMessageGlobal("something went wrong.", context);
        return false;
      }
    } catch (e) {
      showSnackbarMessageGlobal(e.toString(), context);
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // asd asdasd

  // Future<List> _determinePosition() async {
  //   List temp = ["", ""];

  //   LocationPermission permission;
  //   // LocationPermission permission1 = await Geolocator.checkPermission();
  //   // LocationPermission permission3 = await Geolocator.requestPermission();

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return temp;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return temp;
  //   }

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
        padding: EdgeInsets.only(top: 0, left: 0, right: 0),
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: _buildView(height, width),
        ),
      ),
    );
  }

  _buildView(double height, double width) {
    return Form(
      key: _formKey,
      autovalidateMode:
          !isFirstSubmit ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        children: [
          // SizedBox(
          //   height: height * 0.1,
          // ),
          Container(
            height: height * 0.6,
            width: width,
            // ignore: prefer_const_constructors
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/my_trip_logo.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          _buildTitleRow(),
          SizedBox(
            height: 10,
          ),
          _buildTextBox(),
          SizedBox(
            height: 10,
          ),
          _buildButton(),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  MaterialButton _buildButton() {
    return MaterialButton(
      minWidth: MediaQuery.of(context).size.width * 0.75,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 15,
        ),
        child: _isLoading
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
                height: MediaQuery.of(context).size.height * 0.03,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              )
            : Text(
                "TRACK",
                style: TextStyle(
                  // fontFamily: "Rubik",
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
      color: ThemeClass.redColor,
      onPressed: () async {
        // pushNewScreen(
        //   context,
        //   screen: MyTripMapScreen(),
        //   withNavBar: false,
        //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
        // );
        // setState(() {
        //   isFirstSubmit = false;
        // });
        // if (_formKey.currentState!.validate()) {
        //   if (!_isLoading) {
        //     _trackBus();
        //   }
        // }
        // Navigator.pushNamed(context, Routes.myTripMapScreen);
        // callBack();

        var isAvailable = await _getBusLocation();

        if (isAvailable != null && isAvailable == true) {
          await SharedPrefService().setPreviousTicket(_textController.text);
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MyTripMapScreen(busCode: _textController.text),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
      },
    );
  }

  Container _buildTextBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: TextFormField(
        controller: _textController,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderSide: BorderSide(),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ThemeClass.redColor,
              width: 1.0,
            ),
          ),
        ),
        validator: (val) {
          if (val?.length == 0) {
            return "Code cannot be empty.";
          } else {
            return null;
          }
        },
        scrollPadding: EdgeInsets.zero,
        keyboardType: TextInputType.emailAddress,
        cursorColor: ThemeClass.redColor,
        style: new TextStyle(
          fontSize: 20,
          letterSpacing: 2,
          color: ThemeClass.greyColor,
        ),
      ),
    );
  }

  Center _buildTitleRow() {
    return Center(
        child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'ENTER THE ',
            style: TextStyle(
                color: ThemeClass.blackColor,
                fontSize: 18,
                fontWeight: FontWeight.w300),
          ),
          TextSpan(
            text: 'CODE ',
            style: TextStyle(
                color: ThemeClass.redColor,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: 'TO TRACK YOUR BUS',
            style: TextStyle(
                color: ThemeClass.blackColor,
                fontSize: 18,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    ));
  }
}
