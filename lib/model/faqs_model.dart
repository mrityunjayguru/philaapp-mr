// To parse this JSON data, do
//
//     final faQsModel = faQsModelFromJson(jsonString);

import 'dart:convert';

FaQsModel faQsModelFromJson(String str) => FaQsModel.fromJson(json.decode(str));

String faQsModelToJson(FaQsModel data) => json.encode(data.toJson());

class FaQsModel {
  FaQsModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<FAQsData>? data;

  factory FaQsModel.fromJson(Map<String, dynamic> json) => FaQsModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<FAQsData>.from(
                json["message"].map((x) => FAQsData.fromJson(x))),
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

class FAQsData {
  FAQsData({
    this.id,
    this.title,
    this.list,
  });

  String? id;
  String? title;
  List<ListElement>? list;

  factory FAQsData.fromJson(Map<String, dynamic> json) => FAQsData(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        list: json["list"] == null
            ? null
            : List<ListElement>.from(
                json["list"].map((x) => ListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "list": list == null
            ? null
            : List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class ListElement {
  ListElement({
    this.id,
    this.question,
    this.description,
  });

  String? id;
  String? question;
  String? description;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"] == null ? null : json["id"],
        question: json["question"] == null ? null : json["question"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "question": question == null ? null : question,
        "description": description == null ? null : description,
      };
}
