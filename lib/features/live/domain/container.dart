class CContainer {
  final int id;
  final String name;
  final bool valid;
  final double weight;
  final String appId;

  CContainer({
    required this.id,
    required this.name,
    required this.valid,
    required this.weight,
    required this.appId,
  });

  factory CContainer.fromJson(Map<String, dynamic> json) {
    return CContainer(
      id: (json['id'] as num).toInt(),
      name: json['name'],
      valid: json['valid'],
      weight: (json['weight'] as num).toDouble(),
      appId: json['appId'],
    );
  }
}
