class Device {
  final int? deviceId;
  final String deviceSerial;
  final String deviceModel;
  final String? manufactureDate;
  final String? lastCalibration;
  final String status;
  final String? firmwareVersion;
  final String? createdAt;

  Device({
    this.deviceId,
    required this.deviceSerial,
    required this.deviceModel,
    this.manufactureDate,
    this.lastCalibration,
    this.status = 'active',
    this.firmwareVersion,
    this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'],
      deviceSerial: json['deviceSerial'] ?? '',
      deviceModel: json['deviceModel'] ?? '',
      manufactureDate: json['manufactureDate'],
      lastCalibration: json['lastCalibration'],
      status: json['status'] ?? 'active',
      firmwareVersion: json['firmwareVersion'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (deviceId != null) 'deviceId': deviceId,
      'deviceSerial': deviceSerial,
      'deviceModel': deviceModel,
      'manufactureDate': manufactureDate,
      'lastCalibration': lastCalibration,
      'status': status,
      'firmwareVersion': firmwareVersion,
    };
  }
}