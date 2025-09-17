import 'package:get/get.dart';

enum DeviceStatus { active, provisioned, blocked, unknown }

DeviceStatus _statusFrom(String? s) {
  switch (s) {
    case 'active':
      return DeviceStatus.active;
    case 'provisioned':
      return DeviceStatus.provisioned;
    case 'blocked':
      return DeviceStatus.blocked;
    default:
      return DeviceStatus.unknown;
  }
}

class Device {

  final String id;
  final String name;
  final String tenantId;
  final String appId;
  final String appName;
  final String tenantName;
  final DeviceStatus status;


  RxInt? currentContainerId = 0.obs;
  Rx<bool> isMeasuring = false.obs;
  Rx<bool> isOnline = false.obs;


  Device({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.appId,
    required this.appName,
    required this.tenantName,
    this.status = DeviceStatus.unknown,
  });


  factory Device.fromJson(Map<String, dynamic> j) {
    return Device(
      id: j['id'] as String,
      name: j['name'] as String,
      tenantId: j['tenantId'] as String,
      appId: j['appId'] as String,
      appName: j['app']?['appName'] as String? ?? 'Unknown App',
      tenantName: j['tenant']?['tenantName'] as String? ?? 'Unknown Tenant',
      status: _statusFrom(j['status'] as String?),
    );
  }


}