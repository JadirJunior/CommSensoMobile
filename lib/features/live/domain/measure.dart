class Measurement {
  final String name;
  final double value;
  final int sensorId;
  final int containerId;
  final String unit;

  Measurement({
    required this.name,
    required this.value,
    required this.sensorId,
    required this.containerId,
    required this.unit,
  });
}
