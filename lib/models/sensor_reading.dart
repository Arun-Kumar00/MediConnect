class SensorReading {
  final int? readingId;
  final int bandageId;
  final String readingTime;
  final double? phValue;
  final double? oxygenPercent;
  final double? temperatureCelsius;
  final double? enzymeIndex;

  SensorReading({
    this.readingId,
    required this.bandageId,
    required this.readingTime,
    this.phValue,
    this.oxygenPercent,
    this.temperatureCelsius,
    this.enzymeIndex,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      readingId: json['readingId'],
      bandageId: json['bandageId'],
      readingTime: json['readingTime'] ?? '',
      phValue: json['phValue']?.toDouble(),
      oxygenPercent: json['oxygenPercent']?.toDouble(),
      temperatureCelsius: json['temperatureCelsius']?.toDouble(),
      enzymeIndex: json['enzymeIndex']?.toDouble(),
    );
  }
}