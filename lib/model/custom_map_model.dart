// To parse this JSON data, do
//
//     final customMapModel = customMapModelFromJson(jsonString);

import 'dart:convert';

CustomMapModel customMapModelFromJson(String str) =>
    CustomMapModel.fromJson(json.decode(str));

String customMapModelToJson(CustomMapModel data) => json.encode(data.toJson());

class CustomMapModel {
  CustomMapModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  CustomMapData? data;

  factory CustomMapModel.fromJson(Map<String, dynamic> json) => CustomMapModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data:
            json["message"] == null ? null : CustomMapData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "data": message == null ? null : message,
        "message": data == null ? null : data!.toJson(),
      };
}

class CustomMapData {
  CustomMapData({
    this.image,
  });

  String? image;

  factory CustomMapData.fromJson(Map<String, dynamic> json) => CustomMapData(
        image: json["image"] == null ? null : json["image"],
      );

  Map<String, dynamic> toJson() => {
        "image": image == null ? null : image,
      };
}
