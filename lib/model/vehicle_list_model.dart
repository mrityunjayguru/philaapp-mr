import 'dart:convert';

class Device {
  int? id;
  String? imeiNumber;
  String? deviceId;
  String? deviceType;
  String? title;
  String? latitude;
  String? longitude;
  DateTime? lastUpdate;
  String? liveStatus;
  int? lastVisitedStop;
  String? status;
  String? audioAvailable;
  String? security;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  Device({
    this.id,
    this.imeiNumber,
    this.deviceId,
    this.deviceType,
    this.title,
    this.latitude,
    this.longitude,
    this.lastUpdate,
    this.liveStatus,
    this.lastVisitedStop,
    this.status,
    this.audioAvailable,
    this.security,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      imeiNumber: json['imei_number'],
      deviceId: json['device_id'],
      deviceType: json['device_type'],
      title: json['title'],
      latitude: json['latitude'] != null ? json['latitude'].toString() : null,
      longitude: json['longitude'] != null ? json['longitude'].toString() : null,
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
      liveStatus: json['live_status'],
      lastVisitedStop: json['last_visited_stop'],
      status: json['status'],
      audioAvailable: json['audio_available'],
      security: json['security'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imei_number': imeiNumber,
      'device_id': deviceId,
      'device_type': deviceType,
      'title': title,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'last_update': lastUpdate?.toIso8601String(),
      'live_status': liveStatus,
      'last_visited_stop': lastVisitedStop,
      'status': status,
      'audio_available': audioAvailable,
      'security': security,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  static List<Device> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List<dynamic>;
    return List<Device>.from(data.map((item) => Device.fromJson(item)));
  }
}


