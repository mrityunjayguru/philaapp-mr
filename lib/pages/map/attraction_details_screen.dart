import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/places_detail_model.dart';
import 'package:city_sightseeing/model/places_list_model.dart';

import 'package:city_sightseeing/pages/map/stop_details_with_map.dart';

import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/provider/favorite_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:city_sightseeing/widgets/general_widget.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailScreen extends StatefulWidget {
  AttractionDetailScreen({Key? key, required this.placeid}) : super(key: key);
  final String placeid;
  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  var _futureCall;
  @override
  void initState() {
    _futureCall = getPlacesDetails();
    super.initState();
  }

  bool isShowAllText = false;

  showMoreText() {
    setState(() {
      isShowAllText = !isShowAllText;
    });
  }

  Future<PlacesDetailsModel> getPlacesDetails() async {
    try {
      // Map<String, String> queryParameters = {"type": "$value"};

      var response =
          await HttpService.httpGetWithoutToken("place/${widget.placeid}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        PlacesDetailsModel places = PlacesDetailsModel.fromJson(body);

        return places;

        // return coupon;
      } else {
        throw "internal server error";
      }
    } catch (e) {
      if (e is SocketException) {
        debugPrint("socket exception screen :------ $e");

        throw "Socket exception";
      } else if (e is TimeoutException) {
        debugPrint("time out exp :------ $e");

        throw "Time out exception";
      } else {
        debugPrint("attraction details screen:------ $e");

        throw e.toString();
      }
    }
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
        child: FutureBuilder(
            future: _futureCall,
            builder: (context, AsyncSnapshot<PlacesDetailsModel> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.data != null) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildHeader(height, width, snapshot.data!.data),
                            SizedBox(
                              height: 40,
                            ),
                            _buildDescriptionCard(snapshot.data!.data),
                            snapshot.data!.data!.nearestStop != null
                                ? _buildBottomCard(snapshot.data!.data)
                                : SizedBox()
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: _buildDataNotFound("Data Not Found!"),
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: _buildDataNotFound("Data Not Found!"),
                    );
                  }
                } else if (snapshot.hasError) {
                  // return Center(child: Text(snapshot.error.toString()));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _buildDataNotFound(snapshot.error.toString()),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _buildDataNotFound("Data Not Found!"),
                  );
                }
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            }),
      ),
    );
  }

  Center _buildDataNotFound(String text) {
    return Center(child: Text("$text"));
  }

  Container _buildBottomCard(PlacesDetailData? placeDetail) {
    return Container(
      padding: EdgeInsets.all(20),
      color: ThemeClass.blackColor.withOpacity(0.05),
      child: Column(
        children: [
          _buildHeartWithTitle(
              "assets/images/bus_red_icon.png", "  Nearest Bustop"),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 0,
            minLeadingWidth: 28,
            title: Text(placeDetail!.nearestStop!.title.toString()),
            leading: placeDetail.nearestStop!.color != null &&
                    placeDetail.nearestStop!.color != "" &&
                    placeDetail.nearestStop!.color!.toLowerCase() == "mix"
                ? Container(
                    height: 28,
                    width: 28,
                    child: Stack(
                      children: [
                        Wrap(
                          direction: Axis.vertical,
                          children: [
                            Container(
                              width: 14,
                              height: 28,
                              decoration: BoxDecoration(
                                color: ThemeClass.redColor,
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 28,
                              decoration: BoxDecoration(
                                color: ThemeClass.skyblueColor,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            placeDetail.nearestStop!.stopNo.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    color: placeDetail.nearestStop!.color != null &&
                            placeDetail.nearestStop!.color != "" &&
                            placeDetail.nearestStop!.color!.toLowerCase() ==
                                "red"
                        ? ThemeClass.redColor
                        : ThemeClass.skyblueColor,
                    height: 28,
                    width: 28,
                    child: Center(
                      child: Text(
                        placeDetail.nearestStop!.stopNo.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
            trailing: InkWell(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: StopDetailsScreenWithMap(
                    id: placeDetail.nearestStop!.id.toString(),
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  // padding: EdgeInsets.all(200),
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/location_red_icon.png"),
                      // fit: BoxFit.contcain,
                    ),
                  ),
                ),
              ),
            ),
            //
          ),
        ],
      ),
    );
  }

  Container _buildDescriptionCard(PlacesDetailData? placeDetail) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: ThemeClass.blackColor.withOpacity(0.20),
          blurRadius: 1.0, // soften the shadow
          spreadRadius: -6.0, //extend the shadow
          offset: const Offset(
            -1.0, // Move to right 10  horizontally
            8.0, // Move to bottom 10 Vertically
          ),
        )
      ]),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: ThemeClass.whiteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(placeDetail!.description.toString(),
                maxLines: isShowAllText ? 100 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                )),
            SizedBox(
              height: 10,
            ),
            placeDetail.description.toString().length > 150
                ? InkWell(
                    onTap: () {
                      showMoreText();
                    },
                    child: Text(
                      isShowAllText ? "Read less" : "Read more",
                      style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: ThemeClass.redColor,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : SizedBox(),
            Divider(
              height: 30,
              color: ThemeClass.greyColor.withOpacity(0.7),
            ),

            placeDetail.isHours == "1"
                ? placeDetail.hours!
                        .where((element) => element.value != "")
                        .toList()
                        .isNotEmpty
                    ? _buildOpeningHr(placeDetail)
                    : SizedBox()
                : SizedBox(),
            // _buildOpeningHr(placeDetail),
            placeDetail.isCharges == "1"
                ? _buildEntryCharges(placeDetail)
                : SizedBox(),
            _buildMapButtonRow(placeDetail),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Column _buildOpeningHr(PlacesDetailData placeDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildHeartWithTitle("assets/images/timer_icon.png", "  Opening Hours"),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: placeDetail.hours!
              .map(
                (e) => e.value == ""
                    ? SizedBox()
                    : Text(
                        "${e.title}  :  ${e.value}",
                        style: TextStyle(
                            fontSize: 14,
                            color: ThemeClass.blackColor,
                            fontWeight: FontWeight.w500),
                      ),
              )
              .toList(),
        ),
        Divider(
          height: 30,
          color: ThemeClass.greyColor.withOpacity(0.7),
        ),
      ],
    );
  }

  Column _buildEntryCharges(PlacesDetailData placeDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildHeartWithTitle(
            "assets/images/entry_charge_icon.png", "  Entry charges"),
        Text("${placeDetail.charges} ",
            style: TextStyle(
                fontSize: 14,
                color: ThemeClass.blackColor,
                fontWeight: FontWeight.w500)),
        Divider(
          height: 30,
          color: ThemeClass.greyColor.withOpacity(0.7),
        ),
      ],
    );
  }

  Container _buildHeader(
      double height, double width, PlacesDetailData? pleaceDetails) {
    return Container(
      height: height * 0.40,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CachedNetworkImage(
            height: height * 0.35,
            width: width,
            imageUrl: '${pleaceDetails!.image.toString()}',
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
            height: height * 0.35,
            decoration: BoxDecoration(
              // color: Colors.transparent,
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
            bottom: 60,
            // left: 20,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: width,
                child: Column(
                  children: [
                    Text(
                      pleaceDetails.title.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: ThemeClass.whiteColor,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Center(
                        child: Text(
                          pleaceDetails.address.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ThemeClass.whiteColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            // alignment: Alignment.bottomCenter,
            child: Container(
              width: width,
              child: _builfTwobutton(pleaceDetails),
            ),
          )
        ],
      ),
    );
  }

  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  Container _buildMapButtonRow(PlacesDetailData? placeDetail) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          placeDetail!.website == ""
              ? SizedBox()
              : _buildButtonStyle("Website", () {
                  _launchURL(placeDetail.website.toString());
                }),
          placeDetail.phoneNumber == ""
              ? SizedBox()
              : _buildButtonStyle("Call", () {
                  _launchURL("tel:" + placeDetail.phoneNumber.toString());
                  // launch('tel:+91 88888888888');
                }),
          placeDetail.ticketBookingUrl == ""
              ? SizedBox()
              : _buildButtonStyle("Book Ticket", () {
                  _launchURL(placeDetail.ticketBookingUrl.toString());
                }),
        ],
      ),
    );
  }

  Padding _buildButtonStyle(String title, Function callback) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: OutlinedButton(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          // primary: ThemeClass.redColor,
          backgroundColor: ThemeClass.whiteColor,
          side: BorderSide(width: 0.5, color: ThemeClass.redColor),
        ).copyWith(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        onPressed: () {
          callback();
        },
      ),
    );
  }

  Container _buildHeartWithTitle(String imagePath, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
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

  Row _builfTwobutton(PlacesDetailData? pleaceDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<FavoriteService>(builder: (context, favService, child) {
          var item = PlacesListData(
            id: pleaceDetails!.id,
            image: pleaceDetails.image,
            title: pleaceDetails.title,
            description: pleaceDetails.description,
          );

          return InkWell(
            onTap: () {
              if (favService.favPlaces
                  .where((e) {
                    return e.id.toString() == pleaceDetails.id.toString();
                  })
                  .toList()
                  .isEmpty) {
                favService.addFav(item);
              } else {
                favService.removeFromFavList(pleaceDetails.id.toString());
              }
            },
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(favService.favPlaces
                          .where((e) {
                            return e.id.toString() ==
                                pleaceDetails.id.toString();
                          })
                          .toList()
                          .isNotEmpty
                      ? 'assets/images/fav_red_round_icon.png'
                      : 'assets/images/fav_round_icon.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }),
        const SizedBox(
          width: 8,
        ),
        pleaceDetails!.latitude == "" || pleaceDetails.longitude == ""
            ? SizedBox()
            : InkWell(
                onTap: () {
                  _openGoogleMap(
                      pleaceDetails.latitude.toString(),
                      pleaceDetails.longitude.toString(),
                      pleaceDetails.title.toString(),
                      pleaceDetails.googleBusinessUrl.toString());
                },
                child: Container(
                  // padding: EdgeInsets.all(200),
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/location_round_icon.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  _openGoogleMap(
      String latitude, String longitude, String title, String googleUrl) async {
    // String googleUrl =
    //     'https://www.google.com/maps/search/$title/?api=1=$latitude,$longitude';
    // String googleUrl =
    //     'https://www.google.com/maps/search/$title/?api=1=$latitude,$longitude';

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      showSnackbarMessageGlobal("Could not open google map.", context);
    }
  }
}
