import 'package:shared_preferences/shared_preferences.dart';

import '../enums.dart';

class SharedPrefService {
  static SharedPreferences? preferences;

  static Future<void> setOnBoardingScreenDisable(bool data) async {
    preferences = await SharedPreferences.getInstance();
    preferences!.setBool('onbroading', data);
  }

  static Future<bool?> getOnboardingData() async {
    preferences = await SharedPreferences.getInstance();
    var temp = preferences!.getBool("onbroading");

    return temp;
  }

  static Future<void> setToken(String data) async {
    preferences = await SharedPreferences.getInstance();
    preferences!.setString('userToken', data);
  }

  static Future<String?> getToken() async {
    preferences = await SharedPreferences.getInstance();
    var temp = preferences!.getString("userToken");

    return temp;
  }

  Future<void> setFavList(data) async {
    preferences = await SharedPreferences.getInstance();

    preferences!.setString('favorite', data);
  }

  Future<void> removeFavList() async {
    preferences = await SharedPreferences.getInstance();

    preferences!.remove('favorite');
  }

  Future<String?> getFavList() async {
    preferences = await SharedPreferences.getInstance();
    String? temp = preferences!.getString("favorite");
    return temp;
  }

  Future<void> setPreviousTicket(data) async {
    preferences = await SharedPreferences.getInstance();

    preferences!.setString('previousTicket', data);
  }

  Future<void> removePreviousTicket() async {
    preferences = await SharedPreferences.getInstance();

    preferences!.remove('previousTicket');
  }

  Future<String?> getPreviousTicket() async {
    preferences = await SharedPreferences.getInstance();
    String? temp = preferences!.getString("previousTicket");
    return temp;
  }

  Future<void> setLanguage(data) async {
    preferences = await SharedPreferences.getInstance();
    preferences!.setString("language", data);

  }

  Future<String?> getLanguage() async {
    preferences = await SharedPreferences.getInstance();
    String? temp = preferences!.getString("language");
    return temp;
  }

  Future<void> setLanguageName(data) async {
    preferences = await SharedPreferences.getInstance();
    preferences!.setString("languageName", data);

  }

  Future<String?> getLanguageName() async {
    preferences = await SharedPreferences.getInstance();
    String? temp = preferences!.getString("languageName");
    return temp;
  }

   Future<void> setLanguageState(LanguageState state) async {
    preferences = await SharedPreferences.getInstance();
    preferences!.setString("language_state", state.toString());
  }

   Future<LanguageState?> getLanguageState() async {
    preferences = await SharedPreferences.getInstance();
    final String? storedState = preferences!.getString("language_state");
    if (storedState != null) {
      return LanguageState.values.firstWhere((e) => e.toString() == storedState);
    }
    return null; // Default value if no value stored
  }

  // Future<bool?> getBusArrivalNotification() async {
  //   preferences = await SharedPreferences.getInstance();
  //   bool? temp = preferences!.getBool("BusArrivalNotification");
  //   return temp;
  // }

  // Future setBusArrivalNotification(val) async {
  //   preferences = await SharedPreferences.getInstance();

  //   preferences!.setBool('BusArrivalNotification', val);
  // }

  // Future<bool?> getOtherNotification() async {
  //   preferences = await SharedPreferences.getInstance();
  //   bool? temp = preferences!.getBool("OtherNotification");
  //   return temp;
  // }

  // Future<bool?> setOtherNotification(val) async {
  //   preferences = await SharedPreferences.getInstance();

  //   preferences!.setBool('OtherNotification', val);
  // }
}
