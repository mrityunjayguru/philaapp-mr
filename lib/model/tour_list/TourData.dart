import 'Code.dart';

/// id : 1
/// title : "PHILADELPHIA HOP-ON HOP-OFF"
/// image : "uploads/2024/07/landing_page/1721727056_CityHall-Philadelphia-TTD-2020-GettyImages-174530398.jpg.webp"
/// priority : 2
/// is_code_dependency : true
/// code : [{"ticket_number":"123"},{"ticket_number":"1234"}]

class TourData {
  TourData({
      this.id, 
      this.title, 
      this.image, 
      this.priority, 
      this.isCodeDependency, 
      this.status,
      this.code,});

  TourData.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    status = json['status'];
    image = json['image'];
    priority = json['priority'];
    isCodeDependency = json['is_code_dependency'];
    if (json['code'] != null) {
      code = [];
      json['code'].forEach((v) {
        code?.add(Code.fromJson(v));
      });
    }
  }
  int? id;
  String? title;
  String? image;
  String? status;
  int? priority;
  bool? isCodeDependency;
  List<Code>? code;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['image'] = image;
    map['priority'] = priority;
    map['is_code_dependency'] = isCodeDependency;
    if (code != null) {
      map['code'] = code?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}