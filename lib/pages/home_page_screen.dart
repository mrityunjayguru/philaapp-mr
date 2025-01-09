import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:city_sightseeing/generated/assets.dart';
import 'package:city_sightseeing/model/slider_and_stop_model.dart';
import 'package:city_sightseeing/pages/attractions_screen.dart';

import 'package:city_sightseeing/pages/map/stop_details_with_map.dart';
import 'package:city_sightseeing/pages/notification_screen.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/themedata.dart';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.scafoldkey}) : super(key: key);
  final GlobalKey<ScaffoldState> scafoldkey;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _current = 0;
  @override
  void initState(){
    super.initState();
  }
  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: ThemeClass.redColor,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: height,
            width: width,
            child: Consumer<InitialDataService>(
                builder: (context, initdataService, child) {

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildMainHeader(
                        height, width, initdataService.globalSlider),
                    _buildBoxRow(height),
                    _buildButtonList(height, width, initdataService.globalStops)
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Container _buildButtonList(
      double height, double width, List<StopForHome>? stopsList) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.only(left: 17),
          child: Row(
            children: stopsList == null || stopsList.isEmpty
                ? [
                    Center(
                      child: Text("Data not Found!"),
                    )
                  ]
                : stopsList
                    .map((stop) => _buildBottomCardStops(
                        height, width, stop, stopsList.indexOf(stop) + 1))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Container _buildMainHeader(
      double height, double width, List<SliderForHome>? sliderdata) {
    return Container(
      height: height * 0.45,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 400.0,
              enlargeCenterPage: false,
              autoPlay: sliderdata!.length == 1 ? false : true,

              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
              aspectRatio: 4.0,
              // initialPage: 2,
            ),
            items: sliderdata.map((sliderdata) {
              return Builder(
                builder: (BuildContext context) {
                  return InkWell(
                    onTap: () {
                      if (sliderdata.isClickable != null &&
                          (sliderdata.isClickable!.toLowerCase() == "yes" ||
                              sliderdata.isClickable!.toLowerCase() == "true" ||
                              sliderdata.isClickable!.toLowerCase() == "1")) {
                        _launchURL(sliderdata.redirectTo.toString());
                      } else {
                        // pushNewScreen(
                        //   context,
                        //   screen: MapViewScreen(),
                        //   withNavBar: false,
                        //   pageTransitionAnimation:
                        //       PageTransitionAnimation.cupertino,
                        // );
                      }
                    },
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: '${sliderdata.image.toString()}',
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
                        Container(
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
                        Positioned(
                          bottom: 0,
                          left: 20,
                          child: Container(
                            width: width * 0.47,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sliderdata.title.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: ThemeClass.whiteColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  sliderdata.description.toString(),
                                  style: TextStyle(
                                    color: ThemeClass.whiteColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Positioned(child: _buildAppBar()),
          Positioned(
            bottom: 0,
            // right: 0,
            width: width,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: sliderdata.map((url) {
                  int index = sliderdata.indexOf(url);
                  return Container(
                    width: 18.0,
                    height: _current == index ? 3 : 1.5,
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 3.0),
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      color: _current == index
                          ? ThemeClass.redColor
                          : ThemeClass.whiteColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              widget.scafoldkey.currentState!.openDrawer();
            },
            icon: Icon(
              Icons.more_vert,
              size: 35,
              color: ThemeClass.yellowColor,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    var url =
                        Provider.of<InitialDataService>(context, listen: false)
                            .globalCmsData!
                            .chatUrl;
                    _launchURL(url.toString());
                  },
                  child: Container(
                    height: 25,
                    width: 26,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(Assets.imagesIcChat),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  // padding: EdgeInsets.all(10),
                  height: 45,
                  width: 46,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: NotificationScreen(), withNavBar: false,
                        // withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Transform.translate(
                      offset: Offset(0, -10.0),
                      child: Image.asset(Assets.imagesNotification,fit: BoxFit.scaleDown,width: 25,),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _buildBoxRow(double height) {
    return Container(
      margin: const EdgeInsets.all(15),
      color: Colors.white,
      height: height > 700 ? height * 0.11 : height * 0.14,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AttrectionScreen(
                    curIndex: 1,
                  ),
                  withNavBar: false,
                  // withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                color: ThemeClass.skyblueColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      height: 0,
                    ),
                    Container(
                      height: 36,
                      width: 40,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/lankmark_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Center(
                        child: Text(
                          "Things To do",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ThemeClass.whiteColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AttrectionScreen(
                    curIndex: 2,
                  ),
                  withNavBar: false,
                  // withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                color: ThemeClass.orangeColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      height: 36,
                      width: 37,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/dining_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Dining Options",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ThemeClass.whiteColor),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AttrectionScreen(
                    curIndex: 3,
                  ),
                  withNavBar: false,
                  // withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                color: ThemeClass.prupolColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      height: 36,
                      width: 37,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/attractions_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Hotels Options",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ThemeClass.whiteColor),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AttrectionScreen(
                    curIndex: 4,
                  ),
                  withNavBar: false,
                  // withNavBar: true, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                color: ThemeClass.greenColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      height: 36,
                      width: 37,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/shopping_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Shopping Info",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ThemeClass.whiteColor),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _buildBottomCardStops(
      double height, double width, StopForHome stops, int index) {
    return Container(
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
      child: InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: StopDetailsScreenWithMap(
              id: stops.id.toString(),
            ),
            withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Card(
          child: Container(
            color: Colors.white,
            height: height * 0.25,
            width: width * 0.67,
            child: Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: '${stops.image.toString()}',
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
                      Positioned(
                          bottom: 5,
                          right: 5,
                          child: Text(
                            stops.time.toString(),
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text("${stops.title}"),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: stops.color != null &&
                                stops.color != "" &&
                                stops.color!.toLowerCase() == "mix"
                            ? Center(
                                child: FittedBox(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          ThemeClass.redColor,
                                          ThemeClass.skyblueColor,
                                        ],
                                        stops: [0.5, 0],
                                        tileMode: TileMode.clamp,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: Center(
                                      child: Text(
                                        stops.stopNo.toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: FittedBox(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    color: stops.color != null &&
                                            stops.color != "" &&
                                            stops.color!.toLowerCase() == "red"
                                        ? ThemeClass.redColor
                                        : ThemeClass.skyblueColor,
                                    child: Center(
                                      child: Text(
                                        stops.stopNo.toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
