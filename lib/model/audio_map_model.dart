/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

import '../enums.dart';

AudioMapModel audioMapModelFromJson(String str) =>
    AudioMapModel.fromJson(json.decode(str));

String audioMapModelToJson(AudioMapModel data) => json.encode(data.toJson());

class AudioMapModel {
  AudioMapModel({
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  String message;
  String success;
  List<AudioData> data;
  String status;

  factory AudioMapModel.fromJson(Map<dynamic, dynamic> json) => AudioMapModel(
    //todo
        message: json["data"],
        success: json["success"],
        data: List<AudioData>.from(
            json["message"].map((x) => AudioData.fromJson(x))),
        status: json["status"],
      );

  Map<dynamic, dynamic> toJson() => {
        "data": message,
        "success": success,
        "message": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
      };
}

class AudioData {
  AudioData({
    required this.latitude,
    required this.priority,
    required this.showIcon,
    required this.longitude,
    this.angle,
    this.tolerance,
    this.proximity,
    this.isInQueue,
    this.pageId,
    this.play = false,
    this.autoPlayDone = false,
  });

  // "latitude": "23.022505",
  // "longitude": "72.5713621",
  // "priority": 3,
  // "proximity": 20,
  // "show_icon": "no"

  String latitude;
  int? priority;
  ShowIcon showIcon;
  String longitude;
  int? proximity;
  String? angle, tolerance, pageId, isInQueue;
  bool play;
  bool autoPlayDone;

  factory AudioData.fromJson(Map<dynamic, dynamic> json) => AudioData(
        latitude: json["latitude"],
        priority: json["priority"],
        showIcon: showIconValues.map[json["show_icon"]]!,
        longitude: json["longitude"],
        proximity: json["proximity"],
        angle: json["angle"],
        tolerance: json["tolerance"],
        isInQueue: json["is_in_queue"],
        pageId: json["page_id"],
      );

  Map<dynamic, dynamic> toJson() => {
        "latitude": latitude,
        "priority": priority,
        "show_icon": showIconValues.reverse[showIcon],
        "longitude": longitude,
        "proximity": proximity,
      };
}
