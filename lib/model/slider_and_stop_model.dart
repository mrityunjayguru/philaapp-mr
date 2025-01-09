// To parse this JSON data, do
//
//     final sliderAndStopModel = sliderAndStopModelFromJson(jsonString);

import 'dart:convert';

SliderAndStopModel sliderAndStopModelFromJson(String str) =>
    SliderAndStopModel.fromJson(json.decode(str));

String sliderAndStopModelToJson(SliderAndStopModel data) =>
    json.encode(data.toJson());

class SliderAndStopModel {
  SliderAndStopModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  SliderAndStopData? data;

  factory SliderAndStopModel.fromJson(Map<String, dynamic> json) =>
      SliderAndStopModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : SliderAndStopData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class SliderAndStopData {
  SliderAndStopData({
    this.slider,
    this.stops,
  });

  List<SliderForHome>? slider;
  List<StopForHome>? stops;

  factory SliderAndStopData.fromJson(Map<String, dynamic> json) =>
      SliderAndStopData(
        slider: json["slider"] == null
            ? null
            : List<SliderForHome>.from(
                json["slider"].map((x) => SliderForHome.fromJson(x))),
        stops: json["stops"] == null
            ? null
            : List<StopForHome>.from(
                json["stops"].map((x) => StopForHome.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "slider": slider == null
            ? null
            : List<dynamic>.from(slider!.map((x) => x.toJson())),
        "stops": stops == null
            ? null
            : List<dynamic>.from(stops!.map((x) => x.toJson())),
      };
}

class SliderForHome {
  SliderForHome({
    this.id,
    this.title,
    this.tagline,
    this.image,
    this.isClickable,
    this.redirectTo,
    this.buttonText,
    this.description,
  });

  String? id;
  String? title;
  String? tagline;
  String? image;
  String? isClickable;
  String? redirectTo;
  String? buttonText;
  String? description;

  factory SliderForHome.fromJson(Map<String, dynamic> json) => SliderForHome(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        tagline: json["tagline"] == null ? null : json["tagline"],
        image: json["image"] == null ? null : json["image"],
        isClickable: json["is_clickable"] == null ? null : json["is_clickable"],
        redirectTo: json["redirect_to"] == null ? null : json["redirect_to"],
        buttonText: json["button_text"] == null ? null : json["button_text"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "tagline": tagline == null ? null : tagline,
        "image": image == null ? null : image,
        "is_clickable": isClickable == null ? null : isClickable,
        "redirect_to": redirectTo == null ? null : redirectTo,
        "button_text": buttonText == null ? null : buttonText,
        "description": description == null ? null : description,
      };
}

class StopForHome {
  StopForHome(
      {this.id,
      this.image,
      this.title,
      this.description,
      this.time,
      this.latitude,
      this.longitude,
      this.stopNo,
      this.color});

  String? id;
  String? image;
  String? title;
  String? description;
  String? time;
  String? latitude;
  String? longitude;
  String? stopNo;
  String? color;

  factory StopForHome.fromJson(Map<String, dynamic> json) => StopForHome(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        time: json["time"] == null ? null : json["time"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        stopNo: json["stop_no"] == null ? null : json["stop_no"],
        color: json["color"] == null ? null : json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "time": time == null ? null : time,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "stop_no": stopNo == null ? null : stopNo,
        "color": color == null ? null : color,
      };
}
