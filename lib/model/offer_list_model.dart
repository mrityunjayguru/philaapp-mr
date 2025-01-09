// To parse this JSON data, do
//
//     final offerListModel = offerListModelFromJson(jsonString);

import 'dart:convert';

OfferListModel offerListModelFromJson(String str) =>
    OfferListModel.fromJson(json.decode(str));

String offerListModelToJson(OfferListModel data) => json.encode(data.toJson());

class OfferListModel {
  OfferListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<OfferModel>? data;

  factory OfferListModel.fromJson(Map<String, dynamic> json) => OfferListModel(
        success: json["success"] == null ? null : json["success"],
        status: json["status"] == null ? null : json["status"],
        //todo
        message: json["data"] == null ? null : json["data"],
        data: json["message"] == null
            ? null
            : List<OfferModel>.from(
                json["message"].map((x) => OfferModel.fromJson(x))),
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

class OfferModel {
  OfferModel({
    this.id,
    this.image,
    this.title,
    this.description,
    this.referenceId,
    this.isRedirect,
    this.redirectTo,
  });

  String? id;
  String? image;
  String? title;
  String? description;
  String? referenceId;
  String? isRedirect;
  String? redirectTo;

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        referenceId: json["reference_id"] == null
            ? null
            : json["reference_id"].toString(),
        isRedirect:
            json["is_redirect"] == null ? null : json["is_redirect"].toString(),
        redirectTo: json["redirect_to"] == null ? null : json["redirect_to"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "reference_id": referenceId == null ? null : referenceId,
        "is_redirect": isRedirect == null ? null : isRedirect,
        "redirect_to": redirectTo == null ? null : redirectTo,
      };
}
