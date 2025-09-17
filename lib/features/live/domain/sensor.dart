class Sensor {
  final int id;
  final String name;
  final String unit;

  Sensor({
    required this.id,
    required this.name,
    required this.unit,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
    );
  }
}
