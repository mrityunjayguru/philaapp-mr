// To parse this JSON data, do
//
//     final generalInfoModel = generalInfoModelFromJson(jsonString);

import 'dart:convert';

GeneralInfoModel generalInfoModelFromJson(String str) =>
    GeneralInfoModel.fromJson(json.decode(str));

String generalInfoModelToJson(GeneralInfoModel data) =>
    json.encode(data.toJson());

class GeneralInfoModel {
  GeneralInfoModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  GeneralInfoData? data;

  factory GeneralInfoModel.fromJson(Map<String, dynamic> json) =>
      GeneralInfoModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : GeneralInfoData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class GeneralInfoData {
  GeneralInfoData({
    this.title,
    this.appVersion,
    this.copyRightsYear,
    this.xdWeb,
    this.xdMobile,
    this.playstoreUrl,
    this.appstoreUrl,
  });

  String? title;
  String? appVersion;
  String? copyRightsYear;
  String? xdWeb;
  String? xdMobile;
  String? playstoreUrl;
  String? appstoreUrl;

  factory GeneralInfoData.fromJson(Map<String, dynamic> json) =>
      GeneralInfoData(
        title: json["title"] == null ? null : json["title"],
        appVersion: json["app_version"] == null ? null : json["app_version"],
        copyRightsYear:
            json["copy_rights_year"] == null ? null : json["copy_rights_year"],
        xdWeb: json["xd_web"] == null ? null : json["xd_web"],
        xdMobile: json["xd_mobile"] == null ? null : json["xd_mobile"],
        playstoreUrl:
            json["playstore_url"] == null ? null : json["playstore_url"],
        appstoreUrl: json["appstore_url"] == null ? null : json["appstore_url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "app_version": appVersion == null ? null : appVersion,
        "copy_rights_year": copyRightsYear == null ? null : copyRightsYear,
        "xd_web": xdWeb == null ? null : xdWeb,
        "xd_mobile": xdMobile == null ? null : xdMobile,
        "playstore_url": playstoreUrl == null ? null : playstoreUrl,
        "appstore_url": appstoreUrl == null ? null : appstoreUrl,
      };
}
