class MqttConfig {

  final String host;
  final int port;
  final String clientId;
  final String username;
  final String password;
  final bool secure; // Use TLS/SSL
  final bool useWebSocket;

  const MqttConfig({
    required this.host,
    required this.port,
    required this.clientId,
    required this.username,
    required this.password,
    this.secure = false,
    this.useWebSocket = false,
  });

}
