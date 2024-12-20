class Response<T> {
  final bool success;
  final int error;
  final int time;
  final List<Position> positions;

  Response(
      {required this.success,
      required this.error,
      required this.time,
      required this.positions});

  factory Response.fromJson(Map<String, dynamic> json) {
    List<dynamic> positionListJson = json['positions'];

    List<Position> positions = positionListJson
        .map((positionJson) => Position.fromJson(positionJson))
        .toList();

    return Response(
        success: json['success'],
        error: json['error'],
        time: json['time'],
        positions: positions);
  }

  bool get hasError => error != 0;
}

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
        mac: json['mac'],
        time: json['time'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        altitude: json['altitude'],
        zoneid: json['zoneid'],
        zonename: json['zonename']);
  }
}
