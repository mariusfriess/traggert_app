import 'package:traggert_app/models/etag-api.model.dart';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class ETagApiService {
  static final String apiUrl =
      'http://backenddemoneu.traggert.com:8083/api/v0/position/all/tracked';

  static Future<Response> fetchPositions() async {
    try {
      final httpRresponse = await http.get(Uri.parse(apiUrl));

      if (httpRresponse.statusCode == 200) {
        final responseJson = convert.jsonDecode(httpRresponse.body);
        final apiResponse = Response.fromJson(responseJson);

        if (!apiResponse.success || apiResponse.hasError) {
          throw Exception(
              'Fehler beim Abrufen der Positionen. Fehlercode: ${apiResponse.error}');
        }

        return apiResponse;
      } else {
        throw Exception(
            'Fehler beim Abrufen der Positionen. HTTP-Status: ${httpRresponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Abrufen der Positionen: $e');
    }
  }
}
