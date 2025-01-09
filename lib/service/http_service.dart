import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class HttpService {
  // static const String API_BASE_URL = "http://philadelphia.moneytocode.com/api/customer/";
  static const String API_BASE_URL = "https://citysightseeingphila.com/api/customer/";
  // static const String API_BASE_URL = "http://65.1.85.176/api/customer/";

  static Map<String, String> requestHeaders = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };
  // static Map<String, String> requestHeaders = {
  //   HttpHeaders.contentTypeHeader: 'application/json',
  //   "Request-From": Platform.isAndroid ? "Android" : "Ios",
  //   HttpHeaders.acceptHeader: 'application/json',
  //   HttpHeaders.acceptLanguageHeader: 'en'
  // };

  static Future<Response> httpGetWithoutToken(String url) async {
    return http.get(
      Uri.parse(API_BASE_URL + url),
      headers: requestHeaders,
    );
  }

  static Future<Response> httpPost(String url, data) async {
    // var token = await SharedPrefService.getToken();

    return http.post(
      Uri.parse(API_BASE_URL + url),
      body: data,
      // headers: requestHeaders
      //   ..addAll({
      //     'Authorization': 'Bearer ${token.toString()}',
      //   }),
    );
  }

  static Future<Response> httpPostWithoutToken(String url, dynamic data) async {
    print("data httpPostWithoutToken : $data");
    return http.post(
      Uri.parse(API_BASE_URL + url),
      body: data,
      // headers: requestHeaders,
    );
  }
}
// google api key
// AIzaSyB7lTiW5zzMdV4RthiiLaXoanfdJe4yyjo 
