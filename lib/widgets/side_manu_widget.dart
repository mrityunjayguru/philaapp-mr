import 'dart:io';

import 'package:city_sightseeing/global_variable.dart';
import 'package:city_sightseeing/pages/mytrip/track_bus_screen.dart';
import 'package:city_sightseeing/pages/notification_setting_screen.dart';
import 'package:city_sightseeing/pages/sidebar_pages/abous_us_screen.dart';
import 'package:city_sightseeing/pages/sidebar_pages/contact_us_screen.dart';
import 'package:city_sightseeing/pages/sidebar_pages/privacy_policy_screen.dart';
import 'package:city_sightseeing/routes.dart';
import 'package:city_sightseeing/service/provider/general_info_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/audio/audio_tours_screen.dart';
import '../screen/wrapper/audio_coming_soon_screen.dart';

class SideDrawerWidget extends StatefulWidget {
  SideDrawerWidget({Key? key}) : super(key: key);

  @override
  _SideDrawerWidgetState createState() => _SideDrawerWidgetState();
}

class _SideDrawerWidgetState extends State<SideDrawerWidget> {
  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  Future<void> share() async {
    Share.share('Philadelphia sight seeing tours https://www.philadelphiasightseeingtours.com/');
    // await FlutterShare.share(
    //   title: 'Philadelphia',
    //   text: 'Philadelphia sight seeing tours',
    //   linkUrl: 'https://www.philadelphiasightseeingtours.com/',
    //   chooserTitle: 'Philadelphia',
    // );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      height: height,
      width: width * 0.75,
      child: Stack(children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                _buildHeaderImage(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Divider(
                    thickness: 2,
                    color: ThemeClass.redColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                buildListTile("Tickets", () {
                  Navigator.pop(context);
                  _launchURL(GlobalVariable.ticketUrl);
                }),
                buildListTile("My Trip", () {
                  Navigator.pop(context);
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: TrackBusScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }),
                buildListTile("Audio", () {
                  Navigator.pop(context);
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:  AudioTourScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }),
                buildListTile("About us", () {
                  Navigator.pop(context);
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: AboutUsScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }),
                buildListTile("Notification", () {
                  Navigator.pop(context);
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: NotificationSettingScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }),
                buildListTile("FAQs", () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.fAQsSCreen);
                }),
                buildListTile("Privacy Policy", () {
                  final privacyPolicy = Provider.of<InitialDataService>(context,
                              listen: false)
                          .globalCmsData
                          ?.privacyPolicy ??
                      "https://citysightseeingphila.com/api/customer/privacy-policy";
                  Navigator.pop(context);
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: WebViewPage(
                      title: "Privacy Policy",
                      url: privacyPolicy,
                    ),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }),
                buildListTile("Share", () {
                  share();
                }),
                buildListTile("Rate us", () {
                  _rateUS();
                }),
                buildListTile("Contact us", () {
                  Navigator.pop(context);
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ContactUsScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/drawer_image.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  InkWell buildListTile(String title, Function callback) {
    return InkWell(
      onTap: () {
        callback();
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, bottom: 7, top: 7),
              child: Text(
                "$title",
                style: TextStyle(
                    color: ThemeClass.blackColor.withOpacity(0.75),
                    fontSize: 20),
              ),
            ),
            Divider(
              thickness: 1,
            )
          ],
        ),
      ),
    );
  }

  Container _buildHeaderImage() {
    return Container(
      margin: EdgeInsets.all(20),
      height: 110,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/splash_screen_logo.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  _rateUS() async {
    var provider = Provider.of<GeneralInfoService>(context, listen: false);

    var data = provider.generalInfoData;

    if (data == null) {
      await provider.getGeneralInfo();
    }

    if (data != null) {
      if (Platform.isAndroid) {
        Navigator.pop(context);
        _launchURL(data.playstoreUrl.toString());
      } else {
        _launchURL(data.appstoreUrl.toString());
      }
    }
  }
}
