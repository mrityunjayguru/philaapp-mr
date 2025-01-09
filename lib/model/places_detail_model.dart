// To parse this JSON data, do
//
//     final placesDetailsModel = placesDetailsModelFromJson(jsonString);

import 'dart:convert';

PlacesDetailsModel placesDetailsModelFromJson(String str) =>
    PlacesDetailsModel.fromJson(json.decode(str));

String placesDetailsModelToJson(PlacesDetailsModel data) =>
    json.encode(data.toJson());

class PlacesDetailsModel {
  PlacesDetailsModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  PlacesDetailData? data;

  factory PlacesDetailsModel.fromJson(Map<String, dynamic> json) =>
      PlacesDetailsModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : PlacesDetailData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class PlacesDetailData {
  PlacesDetailData({
    this.id,
    this.image,
    this.title,
    this.address,
    this.description,
    this.charges,
    this.isCharges,
    this.website,
    this.phoneNumber,
    this.ticketBookingUrl,
    this.latitude,
    this.longitude,
    this.hours,
    this.googleBusinessUrl,
    this.isHours,
    this.nearestStop,
  });

  String? id;
  String? image;
  String? title;
  String? address;
  String? description;
  String? charges;
  String? isHours;
  String? googleBusinessUrl;
  String? isCharges;

  String? website;
  String? phoneNumber;
  String? ticketBookingUrl;
  String? latitude;
  String? longitude;
  List<Hour>? hours;
  NearestStop? nearestStop;

  factory PlacesDetailData.fromJson(Map<String, dynamic> json) =>
      PlacesDetailData(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        address: json["address"] == null ? null : json["address"],
        isCharges: json["is_charges"] == null ? null : json["is_charges"],
        googleBusinessUrl: json["google_business_url"] == null
            ? null
            : json["google_business_url"],
        description: json["description"] == null ? null : json["description"],
        charges: json["charges"] == null ? null : json["charges"],
        website: json["website"] == null ? null : json["website"],
        phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        ticketBookingUrl: json["ticket_booking_url"] == null
            ? null
            : json["ticket_booking_url"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        isHours: json["is_hours"] == null ? null : json["is_hours"],
        hours: json["hours"] == null
            ? null
            : List<Hour>.from(json["hours"].map((x) => Hour.fromJson(x))),
        nearestStop: json["nearest_stop"] == null
            ? null
            : NearestStop.fromJson(json["nearest_stop"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "address": address == null ? null : address,
        "is_charges": isCharges == null ? null : isCharges,
        "google_business_url":
            googleBusinessUrl == null ? null : googleBusinessUrl,
        "description": description == null ? null : description,
        "charges": charges == null ? null : charges,
        "website": website == null ? null : website,
        "phone_number": phoneNumber == null ? null : phoneNumber,
        "ticket_booking_url":
            ticketBookingUrl == null ? null : ticketBookingUrl,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "is_hours": isHours == null ? null : isHours,
        "hours": hours == null
            ? null
            : List<dynamic>.from(hours!.map((x) => x.toJson())),
        "nearest_stop": nearestStop == null ? null : nearestStop!.toJson(),
      };
}

class Hour {
  Hour({
    this.title,
    this.value,
  });

  String? title;
  String? value;

  factory Hour.fromJson(Map<String, dynamic> json) => Hour(
        title: json["title"] == null ? null : json["title"],
        value: json["value"] == null ? null : json["value"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "value": value == null ? null : value,
      };
}

class NearestStop {
  NearestStop({
    this.id,
    this.image,
    this.title,
    this.stopNo,
    this.description,
    this.time,
    this.color,
    this.latitude,
    this.longitude,
    this.stopImage,
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
  String? stopImage;

  factory NearestStop.fromJson(Map<String, dynamic> json) => NearestStop(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        stopNo: json["stop_no"] == null ? null : json["stop_no"],
        color: json["color"] == null ? null : json["color"],
        description: json["description"] == null ? null : json["description"],
        time: json["time"] == null ? null : json["time"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        stopImage: json["stop_image"] == null ? null : json["stop_image"],
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
        "stop_image": stopImage == null ? null : stopImage,
      };
}
