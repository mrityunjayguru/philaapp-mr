// To parse this JSON data, do
//
//     final offerStopModel = offerStopModelFromJson(jsonString);

import 'dart:convert';

OfferStopModel offerStopModelFromJson(String str) =>
    OfferStopModel.fromJson(json.decode(str));

String offerStopModelToJson(OfferStopModel data) => json.encode(data.toJson());

class OfferStopModel {
  OfferStopModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<StopModel>? data;

  factory OfferStopModel.fromJson(Map<String, dynamic> json) => OfferStopModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<StopModel>.from(
                json["message"].map((x) => StopModel.fromJson(x))),
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

class StopModel {
  StopModel({
    this.id,
    this.image,
    this.title,
    this.stopNo,
    this.description,
    this.time,
    this.color,
    this.latitude,
    this.longitude,
  });

  String? id;
  String? image;
  String? title;
  String? stopNo;
  String? color;
  String? description;
  String? time;
  String? latitude;
  String? longitude;

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        stopNo: json["stop_no"] == null ? null : json["stop_no"],
        color: json["color"] == null ? null : json["color"],
        description: json["description"] == null ? null : json["description"],
        time: json["time"] == null ? null : json["time"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "stop_no": stopNo == null ? null : stopNo,
        "description": description == null ? null : description,
        "time": time == null ? null : time,
        "color": color == null ? null : color,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
      };
}
