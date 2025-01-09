// To parse this JSON data, do
//
//     final getNotificationModel = getNotificationModelFromJson(jsonString);

import 'dart:convert';

GetNotificationModel getNotificationModelFromJson(String str) =>
    GetNotificationModel.fromJson(json.decode(str));

String getNotificationModelToJson(GetNotificationModel data) =>
    json.encode(data.toJson());

class GetNotificationModel {
  GetNotificationModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  NotificationData? data;

  factory GetNotificationModel.fromJson(Map<String, dynamic> json) =>
      GetNotificationModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : NotificationData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class NotificationData {
  NotificationData({
    this.token,
    this.busArrivelNotification,
    this.otherNotification,
  });

  String? token;
  String? busArrivelNotification;
  String? otherNotification;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        token: json["token"] == null ? null : json["token"],
        busArrivelNotification: json["bus_arrivel_notification"] == null
            ? null
            : json["bus_arrivel_notification"],
        otherNotification: json["other_notification"] == null
            ? null
            : json["other_notification"],
      );

  Map<String, dynamic> toJson() => {
        "token": token == null ? null : token,
        "bus_arrivel_notification":
            busArrivelNotification == null ? null : busArrivelNotification,
        "other_notification":
            otherNotification == null ? null : otherNotification,
      };
}
