// To parse this JSON data, do
//
//     final stopDetailModel = stopDetailModelFromJson(jsonString);

import 'dart:convert';

StopDetailModel stopDetailModelFromJson(String str) =>
    StopDetailModel.fromJson(json.decode(str));

String stopDetailModelToJson(StopDetailModel data) =>
    json.encode(data.toJson());

class StopDetailModel {
  StopDetailModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  StopDetailsDataModel? data;

  factory StopDetailModel.fromJson(Map<String, dynamic> json) =>
      StopDetailModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : StopDetailsDataModel.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class StopDetailsDataModel {
  StopDetailsDataModel({
    this.id,
    this.image,
    this.title,
    this.time,
    this.latitude,
    this.longitude,
    this.description,
    this.stopNo,
    this.stopImage,
    this.color,
    this.busTimings,
    this.nearestPlaces,
    this.isStopImage,
    this.nearestLandmarks,
  });

  String? id;
  String? image;
  String? title;
  String? time;
  String? latitude;
  String? longitude;
  String? description;
  String? stopNo;
  String? stopImage;
  String? isStopImage;
  String? color;
  List<BusTiming>? busTimings;
  List<NearestPlace>? nearestPlaces;
  List<NearestLandMark>? nearestLandmarks;

  factory StopDetailsDataModel.fromJson(Map<String, dynamic> json) =>
      StopDetailsDataModel(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        isStopImage:
            json["is_stop_image"] == null ? null : json["is_stop_image"],
        title: json["title"] == null ? null : json["title"],
        time: json["time"] == null ? null : json["time"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        description: json["description"] == null ? null : json["description"],
        stopNo: json["stop_no"] == null ? null : json["stop_no"],
        stopImage: json["stop_image"] == null ? null : json["stop_image"],
        color: json["color"] == null ? null : json["color"],
        busTimings: json["bus_timings"] == null
            ? null
            : List<BusTiming>.from(
                json["bus_timings"].map((x) => BusTiming.fromJson(x))),
        nearestPlaces: json["nearest_places"] == null
            ? null
            : List<NearestPlace>.from(
                json["nearest_places"].map((x) => NearestPlace.fromJson(x))),
        nearestLandmarks: json["nearest_landmarks"] == null
            ? null
            : List<NearestLandMark>.from(json["nearest_landmarks"]
                .map((x) => NearestLandMark.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "time": time == null ? null : time,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "color": color == null ? null : color,
        "description": description == null ? null : description,
        "stop_no": stopNo == null ? null : stopNo,
        "stop_image": stopImage == null ? null : stopImage,
        "is_stop_image": isStopImage == null ? null : isStopImage,
        "bus_timings": busTimings == null
            ? null
            : List<dynamic>.from(busTimings!.map((x) => x.toJson())),
        "nearest_places": nearestPlaces == null
            ? null
            : List<dynamic>.from(nearestPlaces!.map((x) => x.toJson())),
        "nearest_landmarks": nearestLandmarks == null
            ? null
            : List<dynamic>.from(nearestLandmarks!.map((x) => x)),
      };
}

class BusTiming {
  BusTiming({
    this.firstBus,
    this.nextBus,
    this.lastBus,
    this.Frequency,
  });

  String? firstBus;
  String? nextBus;
  String? lastBus;
  String? Frequency;

  factory BusTiming.fromJson(Map<String, dynamic> json) => BusTiming(
        firstBus: json["First Bus"] == null ? null : json["First Bus"],
        nextBus: json["Next Bus"] == null ? null : json["Next Bus"],
        lastBus: json["Last Bus"] == null ? null : json["Last Bus"],
        Frequency: json["Frequency"] == null ? null : json["Frequency"],
      );

  Map<String, dynamic> toJson() => {
        "First Bus": firstBus == null ? null : firstBus,
        "Next Bus": nextBus == null ? null : nextBus,
        "Last Bus": lastBus == null ? null : lastBus,
        "Frequency": Frequency == null ? null : Frequency,
      };
}

class NearestPlace {
  NearestPlace({
    this.id,
    this.image,
    this.title,
    this.description,
  });

  String? id;
  String? image;
  String? title;
  String? description;

  factory NearestPlace.fromJson(Map<String, dynamic> json) => NearestPlace(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
      };
}

class NearestLandMark {
  NearestLandMark({
    this.id,
    this.image,
    this.title,
    this.description,
  });

  String? id;
  String? image;
  String? title;
  String? description;

  factory NearestLandMark.fromJson(Map<String, dynamic> json) =>
      NearestLandMark(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
      };
}
