
import 'TourData.dart';

/// success : true
/// data : [{"id":1,"title":"PHILADELPHIA HOP-ON HOP-OFF","image":"uploads/2024/07/landing_page/1721727056_CityHall-Philadelphia-TTD-2020-GettyImages-174530398.jpg.webp","priority":1}]

class AudioTourListResponse {
  AudioTourListResponse({
      this.success, 
      this.data,});

  AudioTourListResponse.fromJson(dynamic json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(TourData.fromJson(v));
      });
    }
  }
  bool? success;
  List<TourData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}