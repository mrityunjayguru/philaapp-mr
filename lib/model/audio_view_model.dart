import 'dart:convert';

import '../enums.dart';

AudioViewModelList audioViewModelFromJson(String str) =>
    AudioViewModelList.fromJson(json.decode(str));

String audioViewModelToJson(AudioViewModelList data) =>
    json.encode(data.toJson());

class AudioViewModelList {
  AudioViewModelList({
    required this.data,
    required this.success,
    required this.message,
    required this.status,
  });

  AudioViewModel? data;
  String success;
  String? message;
  String status;

  factory AudioViewModelList.fromJson(Map<dynamic, dynamic> json) =>
      AudioViewModelList(
        //todo
        message: json["data"],
        success: json["success"],
        data: json["message"] != null
            ? AudioViewModel.fromJson(json['message'])
            : null,
        status: json["status"],
      );

  Map<dynamic, dynamic> toJson() => {
        "data": data,
        "success": success,
        "message": message,
        "status": status,
      };
}

class AudioViewModel {
  AudioViewModel(
      {this.image,
      this.audio,
      this.description,
      this.title,
      this.showIcon,
      this.isInQueue});

  String? image, isInQueue;
  String? audio;
  String? description;
  String? title;
  ShowIcon? showIcon;

  factory AudioViewModel.fromJson(Map<dynamic, dynamic> json) => AudioViewModel(
      image: json["image"],
      audio: json["audio"],
      description: json["description"],
      title: json["title"],
      isInQueue: json['is_in_queue']);
}
