import 'package:city_sightseeing/routes.dart';
import 'package:city_sightseeing/screen/main_screen.dart';
import 'package:city_sightseeing/screen/overview_screen.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/service/provider/favorite_service.dart';
import 'package:city_sightseeing/service/provider/general_info_service.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateTo());

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
      print("-----firebase token --->${token}");
      var response =
          await HttpService.httpPostWithoutToken("update_firebase_token", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("---------firebase token updated--------");
        await SharedPrefService.setToken(token.toString());
      }
    } catch (e) {}
  }

  Future _getInitalData() async {
    var provider = Provider.of<InitialDataService>(context, listen: false);

    await provider.getOtherNotification();
    await Provider.of<GeneralInfoService>(context, listen: false)
        .getGeneralInfo();
    await provider.getSliderAndStopsData();
    await provider.getCmsPageData();
    await provider.getLanguageData();
    // await provider.getVehicleList();
    await getFireBaseToken();

    await Provider.of<FavoriteService>(context, listen: false)
        .getInLocalStorage();
  }

  _navigateTo() async {
    await _getInitalData();
    // Navigator.pushAndRemoveUntil<void>(
    //   context,
    //   MaterialPageRoute<void>(
    //       builder: (BuildContext context) => OverViewScreen()),
    //   ModalRoute.withName(Routes.overViewScreen),
    // );
    try {
      bool? isSplash = await SharedPrefService.getOnboardingData();
      if (isSplash == null) {
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => OverViewScreen()),
          ModalRoute.withName(Routes.overViewScreen),
        );
      }
      else if (!isSplash) {
        // _checkUserExist();
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => MainScreen()),
          ModalRoute.withName('/main'),
        );
      }
      else {
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => OverViewScreen()),
          ModalRoute.withName(Routes.overViewScreen),
        );
      }
    } catch (e) {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => OverViewScreen()),
        ModalRoute.withName(Routes.overViewScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: ThemeClass.redColor,
        height: height,
        width: width,
        child: Center(
          child: Container(
            // margin: EdgeInsets.all(20),
            height: 120,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/splash_screen_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
