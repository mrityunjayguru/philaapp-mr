// To parse this JSON data, do
//
//     final routesListModel = routesListModelFromJson(jsonString);

import 'dart:convert';

RoutesListModel routesListModelFromJson(String str) =>
    RoutesListModel.fromJson(json.decode(str));

String routesListModelToJson(RoutesListModel data) =>
    json.encode(data.toJson());

class RoutesListModel {
  RoutesListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<RouteModel>? data;

  factory RoutesListModel.fromJson(Map<String, dynamic> json) =>
      RoutesListModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<RouteModel>.from(
                json["message"].map((x) => RouteModel.fromJson(x))),
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

class RouteModel {
  RouteModel({
    this.id,
    this.image,
    this.title,
    this.stopNo,
    this.stopImage,
    this.color,
    this.time,
    this.description,
    this.isStopImage,
    this.latitude,
    this.longitude,
  });

  String? id;
  String? image;
  String? title;
  String? stopNo;
  String? stopImage;
  String? isStopImage;
  String? color;
  String? time;
  String? description;
  String? latitude;
  String? longitude;

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        isStopImage:
            json["is_stop_image"] == null ? null : json["is_stop_image"],
        stopNo: json["stop_no"] == null ? null : json["stop_no"],
        stopImage: json["stop_image"] == null ? null : json["stop_image"],
        color: json["color"] == null ? null : json["color"],
        time: json["time"] == null ? null : json["time"],
        description: json["description"] == null ? null : json["description"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "is_stop_image": isStopImage == null ? null : isStopImage,
        "title": title == null ? null : title,
        "stop_no": stopNo == null ? null : stopNo,
        "stop_image": stopImage == null ? null : stopImage,
        "color": color == null ? null : color,
        "time": time == null ? null : time,
        "description": description == null ? null : description,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
      };
}
