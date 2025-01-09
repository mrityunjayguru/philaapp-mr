import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/places_list_model.dart';
import 'package:city_sightseeing/pages/map/attraction_details_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/provider/favorite_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class AttrectionScreen extends StatefulWidget {
  const AttrectionScreen({Key? key, required this.curIndex}) : super(key: key);
  final int curIndex;

  @override
  _AttrectionScreenState createState() => _AttrectionScreenState();
}

class _AttrectionScreenState extends State<AttrectionScreen>
    with TickerProviderStateMixin {
  bool isMap = false;
  int selectedIndex = 1;
  ScrollController _scrollController = new ScrollController();
  List<String> listOfPeramter = [
    "landmark",
    "dining",
    "attraction",
    "shopping",
    "favorite"
  ];

  bool isFavView = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  var _future;

  @override
  void initState() {
    selectedIndex = widget.curIndex;
    super.initState();
    _future = getPlacesList(listOfPeramter[selectedIndex - 1]);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  sortList(int index) {
    if (index == 5) {
      setState(() {
        isFavView = true;
        selectedIndex = index;
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(seconds: 1), curve: Curves.ease);
      });
    } else {
      setState(() {
        isFavView = false;
        selectedIndex = index;
        if (index == 4) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(seconds: 1),
              curve: Curves.ease);
        } else {
          _scrollController.animateTo(0,
              duration: Duration(seconds: 1), curve: Curves.ease);
        }
      });
      _future = getPlacesList(listOfPeramter[selectedIndex - 1]);
    }
  }

  Future<PlacesListModel> getPlacesList(String value) async {
    try {
      Map<String, String> queryParameters = {"type": "$value"};

      var response =
      await HttpService.httpPostWithoutToken("places", queryParameters);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        PlacesListModel places = PlacesListModel.fromJson(body);

        return places;

        // return coupon;
      } else {
        throw "internal server error";
      }
    } catch (e) {
      if (e is SocketException) {
        // debugPrint("socket exception screen :------ $e");

        throw "Socket exception";
      } else if (e is TimeoutException) {
        // debugPrint("time out exp :------ $e");

        throw "Time out exception";
      } else {
        // debugPrint("home screen :------ $e");

        throw e.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarForMap(
          title: "Attractions",
          showattraction: false,
        ),
      ),
      body: Container(
        // padding: EdgeInsets.only(top: 0, left: 0, right: 0),
        height: height,
        width: width,
        child: Column(
          children: [
            _buildBoxRow(height),
            isFavView
                ? _buildFavoriteView(width)
                : _buildCardList(height, width)
          ],
        ),
      ),
    );
  }

  var leftcount = 0;
  var rightcount = 0;
  bool isScrolling = true;

  Expanded _buildFavoriteView(double width) {
    return Expanded(
        child: GestureDetector(
          onPanUpdate: (details) {
            if (isScrolling) {
              if (details.delta.dx > 0) {
                leftcount++;
                rightcount = 0;
                if (leftcount == 10) {
                  leftcount = 0;
                  if (selectedIndex != 1) {
                    setState(() {
                      isScrolling = false;
                    });
                    sortList(selectedIndex - 1);
                    Future.delayed(Duration(seconds: 1), () {
                      setState(() {
                        isScrolling = true;
                      });
                    });
                  }
                }
              } else {
                rightcount++;
                leftcount = 0;
                if (rightcount == 10) {
                  rightcount = 0;
                  if (selectedIndex != 5) {
                    setState(() {
                      isScrolling = false;
                    });
                    sortList(selectedIndex + 1);
                    Future.delayed(Duration(seconds: 1), () {
                      setState(() {
                        isScrolling = true;
                      });
                    });
                  }
                }
              }
            }
          },
          child: Consumer<FavoriteService>(
              builder: (context, favService, child) {
                return favService.favPlaces.isEmpty
                    ? Container(
                  color: ThemeClass.whiteColor,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: _buildDataNotFound("Data Not Found!"),
                    ),
                  ),
                )
                    : _buildListView(favService, width);
              }),
        ));
  }

  ListView _buildListView(FavoriteService favService, double width) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 40),
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: favService.favPlaces.length,
      itemBuilder: (context, index) {
        var placescart = favService.favPlaces[index];
        return _buildCardItem(width, placescart);
      },
    );
  }

  Expanded _buildCardList(double height, double width) {
    return Expanded(
      child: GestureDetector(
        onPanUpdate: (details) {
          if (isScrolling) {
            if (details.delta.dx > 0) {
              leftcount++;

              rightcount = 0;
              if (leftcount == 15) {
                leftcount = 0;
                if (selectedIndex != 1) {
                  setState(() {
                    isScrolling = false;
                  });
                  sortList(selectedIndex - 1);
                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      isScrolling = true;
                    });
                  });
                }
              }
            } else {
              rightcount++;

              leftcount = 0;

              if (rightcount == 15) {
                rightcount = 0;
                if (selectedIndex != 5) {
                  setState(() {
                    isScrolling = false;
                  });
                  sortList(selectedIndex + 1);
                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      isScrolling = true;
                    });
                  });
                }
              }
            }
          }
        },
        child: FutureBuilder(
            future: _future,
            builder: (context, AsyncSnapshot<PlacesListModel> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.data != null &&
                        snapshot.data!.data!.isNotEmpty) {
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 40),
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data!.data!.length,
                        itemBuilder: (context, index) {
                          var placescart = snapshot.data!.data![index];
                          return _buildCardItem(width, placescart);
                        },
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

              // return Text("data");
            }),
      ),
    );
  }

  Center _buildDataNotFound(String text) {
    return Center(child: Text("$text"));
  }

  InkWell _buildCardItem(double width, PlacesListData places) {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: AttractionDetailScreen(placeid: places.id.toString()),
          withNavBar: false,
          // withNavBar: true, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 154,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: '${places.image.toString()}',
                    imageBuilder: (context, imageProvider) =>
                        Container(
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
                      bottom: 15,
                      left: 10,
                      child: Container(
                        width: width * 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.5,
                              child: Text(places.title.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeClass.whiteColor)),
                            ),
                            Consumer<FavoriteService>(
                                builder: (context, favService, child) {
                                  var item = PlacesListData(
                                    id: places.id,
                                    image: places.image,
                                    title: places.title,
                                    description: places.description,
                                  );

                                  return InkWell(
                                    onTap: () {
                                      if (favService.favPlaces
                                          .where((e) {
                                        return e.id.toString() ==
                                            places.id.toString();
                                      })
                                          .toList()
                                          .isEmpty) {
                                        favService.addFav(item);
                                      } else {
                                        favService.removeFromFavList(
                                            places.id.toString());
                                      }
                                    },
                                    child: Container(
                                      height: 36,
                                      width: 37,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(favService.favPlaces
                                              .where((e) {
                                            return e.id.toString() ==
                                                places.id.toString();
                                          })
                                              .toList()
                                              .isNotEmpty
                                              ? 'assets/images/favorite_yello_fill_icon.png'
                                              : 'assets/images/favorite_yello_icon.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                places.description.toString(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    // fontWeight: FontWeight.w600,
                    color: ThemeClass.blackColor.withOpacity(0.8)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _buildBoxRow(double height) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide(color: ThemeClass.redColor, width: 0.5)),
        color: ThemeClass.redColor.withOpacity(0.1),
      ),
      child: Container(
        margin: const EdgeInsets.all(15),
        // color: ThemeClass.redColor.withOpacity(0.1),
        height: height > 700 ? height * 0.11 : height * 0.14,

        child: SingleChildScrollView(
          controller: _scrollController,
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
                            width: 40,
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
                            child: Center(
                              child: Text(
                                "Things To do",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selectedIndex == 1
                                        ? ThemeClass.whiteColor
                                        : ThemeClass.skyblueColor),
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
                            child: Center(
                              child: Text(
                                "Dining Options",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selectedIndex == 2
                                        ? ThemeClass.whiteColor
                                        : ThemeClass.orangeColor),
                              ),
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
                            child: Center(
                              child: Text(
                                "Hotels Nearby",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selectedIndex == 3
                                        ? ThemeClass.whiteColor
                                        : ThemeClass.prupolColor),
                              ),
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
                            child: Center(
                              child: Text(
                                "Shopping Info",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selectedIndex == 4
                                        ? ThemeClass.whiteColor
                                        : ThemeClass.greenColor),
                              ),
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
                  border: Border.all(color: ThemeClass.redColor),
                ),
                child: InkWell(
                  onTap: () {
                    sortList(5);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    color: selectedIndex == 5
                        ? ThemeClass.redColor
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
                                image: AssetImage(selectedIndex == 5
                                    ? 'assets/images/favorite_white_icon.png'
                                    : 'assets/images/favorite_red_icon.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Text(
                            "Favorite",
                            style: TextStyle(
                                color: selectedIndex == 5
                                    ? ThemeClass.whiteColor
                                    : ThemeClass.redColor),
                          ),
                          SizedBox(
                            height: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
