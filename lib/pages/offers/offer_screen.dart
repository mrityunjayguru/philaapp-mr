import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/offer_list_model.dart';
import 'package:city_sightseeing/model/offer_stop_model.dart';
import 'package:city_sightseeing/pages/map/attraction_details_screen.dart';

import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferScreen extends StatefulWidget {
  OfferScreen({Key? key}) : super(key: key);

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  List<StopModel>? stops;
  bool _isStopLoding = false;

  double scrollPosition = 0;
  ScrollController _scrollController = new ScrollController();
  var _futurecall;
  List<String> listOfPeramter = [
    "landmark",
    "dining",
    "attraction",
    "shopping",
    "favorite"
  ];

  String currentType = "";
  String currentNearByStopId = "";

  bool isVisibleFilter = false;
  int selectedIndex = 0;

  sortList(int index) {
    if (selectedIndex == index) {
      setState(() {
        selectedIndex = 0;
        currentType = "";
        _futurecall = getPlacesList(currentType, currentNearByStopId);
      });
    } else {
      setState(() {
        selectedIndex = index;
        currentType = listOfPeramter[index - 1];
        _futurecall = getPlacesList(currentType, currentNearByStopId);
      });
    }

    //
  }

  int? tempCurrentIndex;
  sortBystops(String stopId, int index) {
    if (tempCurrentIndex == index) {
      setState(() {
        tempCurrentIndex = null;
        currentNearByStopId = "";
        _futurecall = getPlacesList(currentType, currentNearByStopId);
      });
    } else {
      setState(() {
        tempCurrentIndex = index;
        currentNearByStopId = stopId;
        _futurecall = getPlacesList(currentType, currentNearByStopId);
      });
    }
  }

  onSortingPress() {
    setState(() {
      isVisibleFilter = !isVisibleFilter;
    });
  }

  Future<OfferListModel> getPlacesList(String type, String nearestStop) async {
    try {
      Map<String, String> queryParameters = {
        // "offers": "$value",
        "nearest_stop": nearestStop,
        "type": type,
      };

      var response =
          await HttpService.httpPostWithoutToken("offers", queryParameters);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        debugPrint("response====> ${response.body}");
        OfferListModel places = OfferListModel.fromJson(body);

        return places;
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
        debugPrint("home screen :------ $e");

        throw e.toString();
      }
    }
  }

  @override
  void initState() {
    getstops();
    _futurecall = getPlacesList(currentType, currentNearByStopId);
    super.initState();
  }

  getstops() async {
    setState(() {
      _isStopLoding = true;
    });
    try {
      var response = await HttpService.httpGetWithoutToken("offer_stops");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        OfferStopModel offermodel = OfferStopModel.fromJson(body);
        stops = offermodel.data;
      } else {
        throw "internal server error";
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isStopLoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(
            title: "Offers",
            showSorting: true,
            onSortingPress: () {
              onSortingPress();
            }),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0, left: 20, right: 20),
        height: height,
        width: width,
        child: Column(
          children: [
            isVisibleFilter ? _buildHeaderBox(height) : SizedBox(),
            Expanded(
              child: FutureBuilder(
                  future: _futurecall,
                  builder: (context, AsyncSnapshot<OfferListModel> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          if (snapshot.data!.data != null) {
                            if (snapshot.data!.data!.isNotEmpty) {
                              return _buildView(height, snapshot.data!.data);
                            } else {
                              return Container(
                                // height: height,
                                child: _buildDataNotFound1(
                                    "No Offers Found!", snapshot.data!.data),
                              );
                            }
                          } else {
                            return Container(
                                // height: height,
                                child: _buildDataNotFound("Data Not Found!"));
                          }
                        } else {
                          return _buildDataNotFound("Data Not Found!");
                        }
                      } else if (snapshot.hasError) {
                        // return Center(child: Text(snapshot.error.toString()));
                        return _buildDataNotFound(snapshot.error.toString());
                      } else {
                        return _buildDataNotFound("Data Not Found!");
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildDataNotFound(String text) {
    return Container(
        height: 700, color: Colors.red, child: Center(child: Text("$text")));
  }

  void _gestureCallBack(details) {
    if (isVisibleFilter) {
      if (details.delta.dx > 0) {
        leftcount++;
        rightcount = 0;
        if (leftcount == 10) {
          leftcount = 0;

          ;

          if (tempCurrentIndex == null) {
            sortBystops("1", 1);
          } else {
            if (tempCurrentIndex != 0) {
              setState(() {
                if (int.parse(tempCurrentIndex.toString()) <= 3) {
                  scrollPosition = 0;
                } else {
                  scrollPosition = int.parse(tempCurrentIndex.toString()) * 20;
                }
              });

              sortBystops(
                  stops![int.parse(tempCurrentIndex.toString()) - 1]
                      .id
                      .toString(),
                  int.parse(tempCurrentIndex.toString()) - 1);
              _scrollController.animateTo(scrollPosition,
                  duration: Duration(seconds: 1), curve: Curves.ease);
            } else {}
          }
        }
      } else {
        rightcount++;
        leftcount = 0;
        if (rightcount == 10) {
          rightcount = 0;

          if (tempCurrentIndex == null) {
            sortBystops("1", 1);
          } else {
            if (stops!.length != int.parse(tempCurrentIndex.toString()) + 1) {
              setState(() {
                scrollPosition = int.parse(tempCurrentIndex.toString()) * 30;
              });

              sortBystops(
                  stops![int.parse(tempCurrentIndex.toString()) + 1]
                      .id
                      .toString(),
                  int.parse(tempCurrentIndex.toString()) + 1);
              _scrollController.animateTo(scrollPosition,
                  duration: Duration(seconds: 1), curve: Curves.ease);
            } else {}
          }
        }
      }
    }
  }

  GestureDetector _buildDataNotFound1(
      String text, List<OfferModel>? offerData) {
    return GestureDetector(
      onPanUpdate: _gestureCallBack,
      child: Container(
          height: 700,
          color: Colors.transparent,
          child: Center(child: Text("$text"))),
    );
  }

  var leftcount = 0;
  var rightcount = 0;
  Column _buildView(double height, List<OfferModel>? offerData) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanUpdate: _gestureCallBack,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20),
              physics: BouncingScrollPhysics(),
              itemCount: offerData!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: _buildRowCard(offerData[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Column _buildHeaderBox(
    double height,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        _buildBoxRow(height),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Text(
            "Near to stop",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        _isStopLoding
            ? Center(
                child: CircularProgressIndicator(),
              )
            : stops == null || stops!.isEmpty
                ? _buildDataNotFound("Data not Found!")
                : Container(
                    height: 35,
                    child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: stops!.length,
                        itemBuilder: (context, index) {
                          return _buildBox(index, stops![index]);
                        }),
                  ),
        Divider(
          height: 40,
          color: ThemeClass.greyColor.withOpacity(0.7),
        ),
      ],
    );
  }

  InkWell _buildBox(int index, StopModel stop) {
    return InkWell(
      onTap: () {
        sortBystops(stop.id.toString(), index);
      },
      child: Container(
        margin: EdgeInsets.only(right: 5),
        child: AnimatedContainer(
          color: tempCurrentIndex == null
              ? ThemeClass.whiteColor
              : index == tempCurrentIndex
                  ? ThemeClass.redColor
                  : ThemeClass.whiteColor,
          duration: Duration(milliseconds: 500),
          child: Container(
            height: 36,
            width: 36,
            child: Center(
              child: Text(
                "${stop.stopNo}",
                style: TextStyle(
                    fontSize: 20,
                    color: tempCurrentIndex == null
                        ? ThemeClass.redColor
                        : tempCurrentIndex == index
                            ? ThemeClass.whiteColor
                            : ThemeClass.redColor,
                    fontWeight: FontWeight.w300),
              ),
            ),
            decoration: BoxDecoration(
                border: Border.all(color: ThemeClass.redColor, width: 0.5)),
          ),
        ),
      ),
    );
  }

  Container _buildBoxRow(double height) {
    return Container(
      height: height > 700 ? height * 0.11 : height * 0.14,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeClass.skyblueColor),
              ),
              child: InkWell(
                onTap: () {
                  sortList(1);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: selectedIndex == 1
                      ? ThemeClass.skyblueColor
                      : ThemeClass.whiteColor,
                  child: Container(
                    width: 89,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          height: 0,
                        ),
                        Container(
                          height: 36,
                          width: 37,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(selectedIndex == 1
                                  ? 'assets/images/lankmark_icon.png'
                                  : 'assets/images/landmark_blue_icon.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Things To do",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedIndex == 1
                                    ? ThemeClass.whiteColor
                                    : ThemeClass.skyblueColor),
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
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeClass.orangeColor),
              ),
              child: InkWell(
                onTap: () {
                  sortList(2);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: selectedIndex == 2
                      ? ThemeClass.orangeColor
                      : ThemeClass.whiteColor,
                  child: Container(
                    width: 89,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 0,
                        ),
                        Container(
                          height: 36,
                          width: 37,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(selectedIndex == 2
                                  ? 'assets/images/dining_icon.png'
                                  : 'assets/images/dining_orange_icon.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Dining Options",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedIndex == 2
                                    ? ThemeClass.whiteColor
                                    : ThemeClass.orangeColor),
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
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeClass.prupolColor),
              ),
              child: InkWell(
                onTap: () {
                  sortList(3);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: selectedIndex == 3
                      ? ThemeClass.prupolColor
                      : ThemeClass.whiteColor,
                  child: Container(
                    width: 89,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 0,
                        ),
                        Container(
                          height: 36,
                          width: 37,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(selectedIndex == 3
                                  ? 'assets/images/attractions_icon.png'
                                  : 'assets/images/attraction_perpal_icon.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Hotels Nearby",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedIndex == 3
                                    ? ThemeClass.whiteColor
                                    : ThemeClass.prupolColor),
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
            ),
            //
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeClass.greenColor),
              ),
              child: InkWell(
                onTap: () {
                  sortList(4);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: selectedIndex == 4
                      ? ThemeClass.greenColor
                      : ThemeClass.whiteColor,
                  child: Container(
                    width: 89,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 0,
                        ),
                        Container(
                          height: 36,
                          width: 37,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(selectedIndex == 4
                                  ? 'assets/images/shopping_icon.png'
                                  : 'assets/images/shopping_green_icon.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Shopping Info",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedIndex == 4
                                    ? ThemeClass.whiteColor
                                    : ThemeClass.greenColor),
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
            ),
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 4),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: ThemeClass.redColor),
            //   ),
            //   child: InkWell(
            //     onTap: () {
            //       sortList(5);
            //     },
            //     child: AnimatedContainer(
            //       duration: Duration(milliseconds: 500),
            //       color: selectedIndex == 5
            //           ? ThemeClass.redColor
            //           : ThemeClass.whiteColor,
            //       child: Container(
            //         width: 89,
            //         margin: const EdgeInsets.symmetric(horizontal: 3.5),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //           children: [
            //             SizedBox(
            //               height: 0,
            //             ),
            //             Container(
            //               height: 36,
            //               width: 37,
            //               decoration: BoxDecoration(
            //                 image: DecorationImage(
            //                   image: AssetImage(selectedIndex == 5
            //                       ? 'assets/images/favorite_white_icon.png'
            //                       : 'assets/images/favorite_red_icon.png'),
            //                   fit: BoxFit.contain,
            //                 ),
            //               ),
            //             ),
            //             Text(
            //               "Favorite",
            //               style: TextStyle(
            //                   color: selectedIndex == 5
            //                       ? ThemeClass.whiteColor
            //                       : ThemeClass.redColor),
            //             ),
            //             SizedBox(
            //               height: 0,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  void _launchURL(String _url) async {
    try {
      if (!await launch(_url)) throw 'Could not launch $_url';
    } catch (e) {
      debugPrint('======= Something went wrong');
    }
  }

  InkWell _buildRowCard(OfferModel offer) {
    return InkWell(
      onTap: () {
        if (offer.isRedirect == "1") {
          //open web view
          _launchURL(offer.redirectTo.toString());
        } else {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen:
                AttractionDetailScreen(placeid: offer.referenceId.toString()),
            withNavBar: false,
            // withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: _buildImageCard(offer)),
          Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    offer.title.toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeClass.redColor),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    offer.description.toString(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ThemeClass.blackColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildImageCard(OfferModel offer) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ThemeClass.redColor, width: 0.5),
      ),
      height: 128,
      child: Column(
        children: [
          CachedNetworkImage(
            height: 95,
            imageUrl: '${offer.image}',
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: ThemeClass.redColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  "Visit page",
                  style: TextStyle(
                      fontSize: 14,
                      color: ThemeClass.redColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
