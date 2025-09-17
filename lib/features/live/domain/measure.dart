class Measurement {
  final double value;
  final int sensorId;
  final int containerId;
  final DateTime timestamp;

  Measurement({
    required this.timestamp,
    required this.value,
    required this.sensorId,
    required this.containerId,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      timestamp: DateTime.parse(json['timestamp']),
      value: (json['value'] as num).toDouble(),
      sensorId: json['sensorId'],
      containerId: json['containerId'],
    );
  }
}
