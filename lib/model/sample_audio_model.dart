/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

SampleAudioModel sampleAudioModelFromJson(String str) =>
    SampleAudioModel.fromJson(json.decode(str));

String sampleAudioModelToJson(SampleAudioModel data) =>
    json.encode(data.toJson());

class SampleAudioModel {
  SampleAudioModel({
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  String message;
  String success;
  SampleData? data;
  String status;

  factory SampleAudioModel.fromJson(Map<dynamic, dynamic> json) =>
      SampleAudioModel(
        //todo
        message: json["data"],
        success: json["success"],
        data: json["message"] != null ? SampleData.fromJson(json["message"]) : null,
        status: json["status"],
      );

  Map<dynamic, dynamic> toJson() => {
        "data": data?.toJson(),
        "success": success,
        "message": message,
        "status": status,
      };
}

class SampleData {
  SampleData({
    required this.landingPageData,
    required this.audio,
  });

  LandingPageData landingPageData;
  Audio audio;

  factory SampleData.fromJson(Map<dynamic, dynamic> json) => SampleData(
        landingPageData: LandingPageData.fromJson(json["landing_page_data"]),
        audio: Audio.fromJson(json["audio"]),
      );

  Map<dynamic, dynamic> toJson() => {
        "landing_page_data": landingPageData.toJson(),
        "audio": audio.toJson(),
      };
}

class Audio {
  Audio({
    required this.audio,
  });

  String? audio;

  factory Audio.fromJson(Map<dynamic, dynamic> json) => Audio(
        audio: json["audio"],
      );

  Map<dynamic, dynamic> toJson() => {
        "audio": audio,
      };
}

class LandingPageData {
  LandingPageData({
    this.image,
    this.routeLength,
    this.routeTime,
    this.numberOfStops,
    this.description,
    this.title,
    this.status,
  });

  String? image;
  String? routeLength;
  String? routeTime;
  String? numberOfStops;
  String? description;
  String? title;
  String? status;

  factory LandingPageData.fromJson(Map<dynamic, dynamic> json) =>
      LandingPageData(
        image: json["image"],
        routeLength: json["route_length"],
        routeTime: json["route_time"],
        numberOfStops: json["number_of_stops"],
        description: json["description"],
        title: json["title"],
        status: json["status"],
      );

  Map<dynamic, dynamic> toJson() => {
        "image": image,
        "route_length": routeLength,
        "route_time": routeTime,
        "number_of_stops": numberOfStops,
        "description": description,
        "title": title,
        "status": status,
      };
}
