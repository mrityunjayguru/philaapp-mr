import 'package:city_sightseeing/routes.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';

class MapshortDetailsScreen extends StatefulWidget {
  MapshortDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MapshortDetailsScreen> createState() => _MapshortDetailsScreenState();
}

class _MapshortDetailsScreenState extends State<MapshortDetailsScreen> {
  bool isMap = false;
  toggleMap() {
    setState(() {
      isMap = !isMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarForMap(),
      ),
      body: Container(
        // padding: EdgeInsets.only(top: 0, left: 0, right: 0),
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 15, left: 0, right: 0, bottom: 15),
            // padding: EdgeInsets.only(top: 15, left: 0, right: 0, bottom: 15),
            child: Column(
              children: [
                _buildMapButtonRow(),
                const SizedBox(
                  height: 15,
                ),
                _buildMapView(height, width),
                _buildCard(),
                _builfTwobutton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card _buildCard() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 149,
              width: 149,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://media.istockphoto.com/photos/downtown-building-located-at-the-hospital-3d-rendering-picture-id1282488617?b=1&k=20&m=1282488617&s=170667a&w=0&h=pJ6RUM6ezLAgCeU_J09M_5OKkIJSPMd--dx3_OKC8Mo='),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "The Ritz Carlton",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                      "The Ritz-Carlton, Philadelphia is housed within the walls of a magnificent neoclassical bank building that dates back to 1908….",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      )),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Transform _builfTwobutton() {
    return Transform.translate(
      offset: Offset(0, -30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // padding: EdgeInsets.all(200),
            height: 61,
            width: 61,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/details_rounded_red.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, Routes.mapFullScreen);
            },
            child: Container(
              // padding: EdgeInsets.all(200),
              height: 61,
              width: 61,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/location_red_rounded.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildMapView(double height, double width) {
    return Container(
      height: height * 0.4,
      width: width,
      child: InteractiveViewer(
        scaleEnabled: true,
        maxScale: 5.0,
        child: Container(
          height: height * 0.4,
          width: width,
          decoration: BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(color: ThemeClass.redColor)),
            image: DecorationImage(
              image: NetworkImage(isMap
                  ? "https://images.unsplash.com/photo-1586449480558-33ae22ffc60d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8Z29vZ2xlJTIwbWFwfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60"
                  : 'https://media.istockphoto.com/photos/downtown-building-located-at-the-hospital-3d-rendering-picture-id1282488617?b=1&k=20&m=1282488617&s=170667a&w=0&h=pJ6RUM6ezLAgCeU_J09M_5OKkIJSPMd--dx3_OKC8Mo='),
              fit: BoxFit.fill,
            ),
          ),
        ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              // primary: ThemeClass.redColor,
              backgroundColor:
                  isMap ? ThemeClass.yellowColor : ThemeClass.whiteColor,
              side: BorderSide(width: 1.0, color: ThemeClass.redColor),
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
              'Custom View',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              // primary: ThemeClass.redColor,
              backgroundColor:
                  !isMap ? ThemeClass.yellowColor : ThemeClass.whiteColor,
              side: BorderSide(width: 1.0, color: ThemeClass.redColor),
            ),
            onPressed: () {
              if (isMap) {
                toggleMap();
              }

              print('Pressed');
            },
          )
        ],
      ),
    );
  }
}
