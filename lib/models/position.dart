class Position {
  final String mac;
  final int time;
  final double longitude;
  final double latitude;
  final int altitude;
  final String zoneid;
  final String zonename;

  Position(
      {required this.mac,
      required this.time,
      required this.longitude,
      required this.latitude,
      required this.altitude,
      required this.zoneid,
      required this.zonename});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
        mac: json['mac'] as String,
        time: json['time'] as int,
        longitude: json['longitude'] as double,
        latitude: json['latitude'] as double,
        altitude: json['altitude'] as int,
        zoneid: json['zoneid'] as String,
        zonename: json['zonename'] as String);
  }
}
