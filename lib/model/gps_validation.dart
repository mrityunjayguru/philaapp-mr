/// id : 2
/// gps_enabled : 0
/// updated_at : "2024-08-29 06:26:10"
/// created_at : "2024-08-29 05:51:55"

class GpsValidation {
  GpsValidation({
      this.id, 
      this.gpsEnabled, 
      this.updatedAt, 
      this.createdAt,});

  GpsValidation.fromJson(dynamic json) {
    id = json['id'];
    gpsEnabled = json['gps_enabled'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }
  int? id;
  int? gpsEnabled;
  String? updatedAt;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['gps_enabled'] = gpsEnabled;
    map['updated_at'] = updatedAt;
    map['created_at'] = createdAt;
    return map;
  }

}