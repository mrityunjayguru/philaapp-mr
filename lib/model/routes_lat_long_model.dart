// To parse this JSON data, do
//
//     final routesLatLongListModel = routesLatLongListModelFromJson(jsonString);

import 'dart:convert';

RoutesLatLongListModel routesLatLongListModelFromJson(String str) =>
    RoutesLatLongListModel.fromJson(json.decode(str));

String routesLatLongListModelToJson(RoutesLatLongListModel data) =>
    json.encode(data.toJson());

class RoutesLatLongListModel {
  RoutesLatLongListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<LatLongModel>? data;

  factory RoutesLatLongListModel.fromJson(Map<String, dynamic> json) =>
      RoutesLatLongListModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<LatLongModel>.from(
                json["message"].map((x) => LatLongModel.fromJson(x))),
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

class LatLongModel {
  LatLongModel({
    this.id,
    this.latitude,
    this.longitude,
  });

  String? id;
  String? latitude;
  String? longitude;

  factory LatLongModel.fromJson(Map<String, dynamic> json) => LatLongModel(
        id: json["id"] == null ? null : json["id"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
      };
}
