class Alert {
  final int? alertId;
  final int bandageId;
  final int patientId;
  final String alertType;
  final String severity;
  final String message;
  final String triggeredAt;
  final String status;

  Alert({
    this.alertId,
    required this.bandageId,
    required this.patientId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.triggeredAt,
    this.status = 'active',
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      alertId: json['alertId'],
      bandageId: json['bandageId'],
      patientId: json['patientId'],
      alertType: json['alertType'] ?? '',
      severity: json['severity'] ?? '',
      message: json['message'] ?? '',
      triggeredAt: json['triggeredAt'] ?? '',
      status: json['status'] ?? 'active',
    );
  }
}