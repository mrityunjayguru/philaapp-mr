// To parse this JSON data, do
//
//     final busTrackModel = busTrackModelFromJson(jsonString);

import 'dart:convert';

BusTrackModel busTrackModelFromJson(String str) =>
    BusTrackModel.fromJson(json.decode(str));

String busTrackModelToJson(BusTrackModel data) => json.encode(data.toJson());

class BusTrackModel {
  BusTrackModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<BusTrackData>? data;

  factory BusTrackModel.fromJson(Map<String, dynamic> json) => BusTrackModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<BusTrackData>.from(
                json["message"].map((x) => BusTrackData.fromJson(x))),
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

class BusTrackData {
  BusTrackData({
    this.deviceId,
    this.deviceType,
    this.distance,
    this.title,
    this.status,
    this.lastUpdate,
    this.latitude,
    this.longitude,
    this.time,
    this.minutes,
    this.isShow,
  });

  String? deviceId;
  String? deviceType;
  String? distance;
  String? title;
  String? status;
  String? lastUpdate;
  String? latitude;
  String? longitude;
  String? time;
  String? minutes;
  String? isShow;

  factory BusTrackData.fromJson(Map<String, dynamic> json) => BusTrackData(
        deviceId: json["deviceId"] == null ? null : json["deviceId"],
        distance: json["distance"] == null ? null : json["distance"],
        deviceType: json["device_type"] == null ? null : json["device_type"],
        title: json["title"] == null ? null : json["title"],
        status: json["status"] == null ? null : json["status"],
        lastUpdate: json["lastUpdate"] == null ? null : json["lastUpdate"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        time: json["time"] == null ? null : json["time"],
        minutes: json["minutes"] == null ? null : json["minutes"],
        isShow: json["is_show"] == null ? null : json["is_show"],
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId == null ? null : deviceId,
        "device_type": deviceType == null ? null : deviceType,
        "distance": distance == null ? null : distance,
        "title": title == null ? null : title,
        "status": status == null ? null : status,
        "lastUpdate": lastUpdate == null ? null : lastUpdate,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "time": time == null ? null : time,
        "minutes": minutes == null ? null : minutes,
        "is_show": isShow == null ? null : isShow,
      };
}
