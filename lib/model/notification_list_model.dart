// To parse this JSON data, do
//
//     final notificationListModel = notificationListModelFromJson(jsonString);

import 'dart:convert';

NotificationListModel notificationListModelFromJson(String str) =>
    NotificationListModel.fromJson(json.decode(str));

String notificationListModelToJson(NotificationListModel data) =>
    json.encode(data.toJson());

class NotificationListModel {
  NotificationListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<NotificationData>? data;

  factory NotificationListModel.fromJson(Map<String, dynamic> json) =>
      NotificationListModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<NotificationData>.from(
                json["message"].map((x) => NotificationData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class NotificationData {
  NotificationData(
      {this.notificationId,
      this.title,
      this.message,
      this.type,
      this.typeId,
      this.dateTime,
      this.image});

  String? notificationId;
  String? title;
  String? message;
  String? type;
  String? typeId;
  String? dateTime;
  String? image;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        notificationId:
            json["notification_id"] == null ? null : json["notification_id"],
        title: json["title"] == null ? null : json["title"],
        message: json["message"] == null ? null : json["message"],
        type: json["type"] == null ? null : json["type"],
        typeId: json["type_id"] == null ? null : json["type_id"],
        dateTime: json["date_time"] == null ? null : json["date_time"],
        image: json["image"] == null ? null : json["image"],
      );

  Map<String, dynamic> toJson() => {
        "notification_id": notificationId == null ? null : notificationId,
        "title": title == null ? null : title,
        "message": message == null ? null : message,
        "type": type == null ? null : type,
        "type_id": typeId == null ? null : typeId,
        "date_time": dateTime == null ? null : dateTime,
        "image": image == null ? null : image,
      };
}
