import 'package:carousel_slider/carousel_slider.dart';
import 'package:city_sightseeing/generated/assets.dart';
import 'package:city_sightseeing/screen/main_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class OverViewScreen extends StatefulWidget {
  OverViewScreen({Key? key}) : super(key: key);

  @override
  _OverViewScreenState createState() => _OverViewScreenState();
}

class _OverViewScreenState extends State<OverViewScreen> {
  List<String> sliderList = [
    Assets.overviewOverviewScreen1,
    Assets.overviewOverviewScreen2,
    Assets.overviewOverviewScreen3,
    Assets.overviewOverviewScreen4,
    Assets.overviewOverviewScreen5,
  ];
  bool isshowButton = false;
  var _current = 0;
  bool isLastIndex = false;

  changeIndex(int index) {
    if (index + 1 == sliderList.length) {
      setState(() {
        isshowButton = true;
      });
    }
    setState(() {
      _current = index;
    });
  }

  @override
  void initState() {
    setonBoardinfOff();
    // getFireBaseToken();
    super.initState();
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  getFireBaseToken() async {
    try {
      var token = await messaging.getToken(
          // vapidKey: "BGpdLRs......",
          );

      var map = new Map<String, dynamic>();
      map['token'] = token;

      var response =
          await HttpService.httpPostWithoutToken("update_firebase_token", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("----------firebase token updated---------");
        await SharedPrefService.setToken(token.toString());
      }
    } catch (e) {}
  }

  setonBoardinfOff() async {
    await SharedPrefService.setOnBoardingScreenDisable(false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ThemeClass.redColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: ThemeClass.redColor,
      ),
      // extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                height: double.infinity,
                onPageChanged: (index, reason) {
                  changeIndex(index);
                },
                // aspectRatio:1.0

                // initialPage: 2,
              ),
              items: sliderList
                  .map((e) => _buildCards(e,height, _current))
                  .toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !isshowButton
                    ? InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MainScreen()),
                            ModalRoute.withName('/main'),
                          );
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(
                              fontSize: 18,
                              color: ThemeClass.whiteColor.withOpacity(0.7),
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    : Spacer(),
                Spacer(),
                Wrap(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: sliderList.map((url) {
                          int index = sliderList.indexOf(url);
                          return Container(
                            width: 18.0,
                            height: _current == index ? 3 : 1.5,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              // shape: BoxShape.circle,
                              color: _current == index
                                  ? ThemeClass.whiteColor
                                  : ThemeClass.greyColor,
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
                Spacer(),
                isshowButton
                    ? InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MainScreen()),
                            ModalRoute.withName('/main'),
                          );
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(
                              fontSize: 18,
                              color: ThemeClass.whiteColor.withOpacity(0.7),
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    : Spacer(),
              ],
            ),
          ),
          SizedBox(height: 15,)
        ],
      ),
    );
  }

  Container _buildCards(String imageName, double height, index) {

    return  Container(
      // margin: EdgeInsets.all(20),
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageName),
          fit: BoxFit.contain,
        ),
      ),
    );
    // return Column(
    //   children: [
    //     Container(
    //       // margin: EdgeInsets.all(20),
    //       height: height,
    //       decoration: BoxDecoration(
    //         image: DecorationImage(
    //           image: AssetImage(imageName),
    //           fit: BoxFit.fitWidth,
    //         ),
    //       ),
    //     ),
    //     // Container(
    //     //   padding: EdgeInsets.symmetric(vertical: 15),
    //     //   child: Text(
    //     //     "HOP-ON HOP-OFF TOUR ${index + 1}",
    //     //     style: TextStyle(
    //     //         fontSize: 20,
    //     //         color: ThemeClass.redColor,
    //     //         fontWeight: FontWeight.bold),
    //     //   ),
    //     // ),
    //     // Container(
    //     //   padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    //     //   child: Text(
    //     //     "Experience Philadelphia with an expert guided tour of the city. Choose from one-, two-, and three-day tickets with a total of 28 stops and multi-language audio commentary.",
    //     //     textAlign: TextAlign.center,
    //     //     style: TextStyle(
    //     //         fontSize: 16,
    //     //         color: ThemeClass.blackColor,
    //     //         fontWeight: FontWeight.normal),
    //     //   ),
    //     // ),
    //   ],
    // );
  }
}
