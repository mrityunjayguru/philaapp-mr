// To parse this JSON data, do
//
//     final cmsPageModel = cmsPageModelFromJson(jsonString);

import 'dart:convert';

CmsPageModel cmsPageModelFromJson(String str) =>
    CmsPageModel.fromJson(json.decode(str));

String cmsPageModelToJson(CmsPageModel data) => json.encode(data.toJson());

class CmsPageModel {
  CmsPageModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  CmsPageData? data;

  factory CmsPageModel.fromJson(Map<String, dynamic> json) => CmsPageModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null ? null : CmsPageData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class CmsPageData {
  CmsPageData(
      {this.about,
      this.contact,
      this.terms,
      this.privacyPolicy,
      this.chatUrl,
      this.ticketUrl,
      this.centerLatitude,
      this.centerLongitude,
      this.refressTime});

  String? about;
  String? contact;
  String? terms;
  String? chatUrl;
  String? ticketUrl;
  String? privacyPolicy;
  String? refressTime;
  String? centerLatitude;
  String? centerLongitude;

  factory CmsPageData.fromJson(Map<String, dynamic> json) => CmsPageData(
        chatUrl: json["chat_url"] == null ? null : json["chat_url"],
        about: json["about"] == null ? null : json["about"],
        contact: json["contact"] == null ? null : json["contact"],
        ticketUrl: json["ticket_url"] == null ? null : json["ticket_url"],
        terms: json["terms"] == null ? null : json["terms"],
        centerLatitude:
            json["center_latitude"] == null ? null : json["center_latitude"],
        centerLongitude:
            json["center_longitude"] == null ? null : json["center_longitude"],
        refressTime: json["refress_time"] == null ? null : json["refress_time"],
        privacyPolicy:
            json["privacy_policy"] == null ? null : json["privacy_policy"],
      );

  Map<String, dynamic> toJson() => {
        "about": about == null ? null : about,
        "chat_url": chatUrl == null ? null : chatUrl,
        "ticket_url": ticketUrl == null ? null : ticketUrl,
        "contact": contact == null ? null : contact,
        "terms": terms == null ? null : terms,
        "privacy_policy": privacyPolicy == null ? null : privacyPolicy,
        "refress_time": refressTime == null ? null : refressTime,
        "center_latitude": refressTime == null ? null : refressTime,
        "center_longitude": refressTime == null ? null : refressTime,
      };
}
