// To parse this JSON data, do
//
//     final placesListModel = placesListModelFromJson(jsonString);

import 'dart:convert';

PlacesListModel placesListModelFromJson(String str) =>
    PlacesListModel.fromJson(json.decode(str));

String placesListModelToJson(PlacesListModel data) =>
    json.encode(data.toJson());

class PlacesListModel {
  PlacesListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<PlacesListData>? data;

  factory PlacesListModel.fromJson(Map<String, dynamic> json) =>
      PlacesListModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? []
            : List<PlacesListData>.from(
                json["message"].map((x) => PlacesListData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null
            ? null
            : List<PlacesListData>.from(data!.map((x) => x.toJson())),
      };
}

class PlacesListData {
  PlacesListData(
      {this.id,
      this.image,
      this.type,
      this.title,
      this.description,
      this.googleBusinessUrl,
      this.latitude,
      this.longitude});

  String? id;
  String? image;
  String? title;
  String? type;
  String? googleBusinessUrl;
  String? description;
  String? latitude;
  String? longitude;
  factory PlacesListData.fromJson(Map<String, dynamic> json) => PlacesListData(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        type: json["type"] == null ? null : json["type"],
        description: json["description"] == null ? null : json["description"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        googleBusinessUrl: json["google_business_url"] == null
            ? null
            : json["google_business_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "type": type == null ? null : type,
        "google_business_url":
            googleBusinessUrl == null ? null : googleBusinessUrl,
        "description": description == null ? null : description,
        "latitude": description == null ? null : description,
        "longitude": description == null ? null : description,
      };
}
