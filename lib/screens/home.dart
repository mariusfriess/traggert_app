import 'dart:convert' as convert;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:traggert_app/models/etag-api.model.dart';
import 'package:traggert_app/services/etag-api.service.dart';

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
      final apiResponse = await ETagApiService.fetchPositions();

      if (apiResponse.success && !apiResponse.hasError) {
        List<Position> positions = apiResponse.positions;

        setState(() {
          this.positions = positions;
          filteredPositions = positions;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "$e";
      });
    }
  }

  void _sortPositionsByMac() {
    setState(() {
      positions.sort((a, b) => a.mac.compareTo(b.mac));
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
