import 'dart:convert';

LanguageListModel languageListModelFromJson(String str) =>
    LanguageListModel.fromJson(json.decode(str));

String languageListModelToJson(LanguageListModel data) =>
    json.encode(data.toJson());

class LanguageListModel {
  LanguageListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  List<LanguageModel>? data;
  String? message;

  factory LanguageListModel.fromJson(Map<String, dynamic> json) =>
      LanguageListModel(
        success: json["success"],
        status: json["status"],
        //todo
        data: json["message"] != null
            ? List<LanguageModel>.from(
                json["message"].map((x) => LanguageModel.fromJson(x)))
            : null,
        message: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "status": status,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : null,
        "message": message,
      };
}

class LanguageModel {
  LanguageModel({
    required this.languages,
    required this.tag,
    required this.status,
    this.pageId
  });

  String languages;
  String tag;
  String status;
  String? pageId;

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        languages: json["languages"],
        tag: json["tag"],
        status: json["status"],
        pageId: json["page_id"],
      );

  Map<String, dynamic> toJson() => {
        "languages": languages,
        "tag": tag,
        "status": status,
        "page_id": pageId,
      };
}
