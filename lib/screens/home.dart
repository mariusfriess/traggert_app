import 'dart:convert' as convert;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:traggert_app/models/position.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl =
      'http://backenddemoneu.traggert.com:8083/api/v0/position/all/tracked';

  String errorMessage = '';

  List<Position> positions = [];
  List<Position> filteredPositions = [];

  @override
  void initState() {
    super.initState();

    _fetchPositions();
  }

  Future<void> _fetchPositions() async {
    setState(() {
      positions = [];
      filteredPositions = [];
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Http request had no errors
        final responseJson = convert.jsonDecode(response.body);

        if (responseJson['success'] == true && responseJson['error'] == 0) {
          // Internal API was successful
          List<dynamic> positionListJson = responseJson['positions'];

          positions = positionListJson
              .map((positionJson) => Position.fromJson(positionJson))
              .toList();

          setState(() {
            filteredPositions = positions;
          });
        } else {
          setState(() {
            // Internal API returned an error
            errorMessage =
                "Die API hat einen Fehler beim Abrufen der Daten. Fehlercode: ${responseJson['error']}";
          });
        }
      } else {
        // Http request had an error
        setState(() {
          errorMessage =
              'Fehler beim Abrufen der Positionen. HTTP-Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Error while fetching data
      setState(() {
        errorMessage =
            'Ein unerwarteter Fehler ist aufgetreten. Fehlermeldung: $e';
      });
    }
  }

  void _sortPositionsByMac() {
    setState(() {
      filteredPositions.sort((a, b) => a.mac.compareTo(b.mac));
    });
  }

  void _filterPositionsByMacPrefix(String prefix) {
    setState(() {
      filteredPositions = positions
          .where((position) => position.mac.startsWith(prefix))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traggert Demo App'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (positions.isEmpty && errorMessage.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage.isNotEmpty)
              Text(errorMessage)
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  // Top row with filter and sort buttons
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Filtere anhand der Mac-Adresse',
                            border: OutlineInputBorder()),
                        onChanged: _filterPositionsByMacPrefix,
                      ),
                    ),
                    IconButton(
                      onPressed: _sortPositionsByMac,
                      icon: Icon(Icons.sort),
                    )
                  ],
                ),
              ),
            if (filteredPositions.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("Keine Positionen gefunden"),
                ),
              )
            else
              Expanded(
                // Result: List of positions
                child: ListView.builder(
                  itemCount: filteredPositions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text("Mac: ${filteredPositions[index].mac}"),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Latitude: ${filteredPositions[index].latitude}"),
                              Text(
                                  "Longitude: ${filteredPositions[index].longitude}"),
                            ]),
                      ),
                    );
                  },
                ),
              ),
            // Reload data
            ElevatedButton(
              onPressed: _fetchPositions,
              child: Text("Daten erneut laden"),
            ),
          ],
        ),
      ),
    );
  }
}
