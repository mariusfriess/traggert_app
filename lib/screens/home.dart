import 'package:flutter/material.dart';

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
  String filter = '';

  @override
  void initState() {
    super.initState();

    _fetchPositions();
  }

  Future<void> _fetchPositions() async {
    setState(() {
      positions = [];
      errorMessage = '';
      filter = '';
    });

    try {
      final apiResponse = await ETagApiService.fetchPositions();

      setState(() {
        positions = apiResponse.positions;
      });
    } catch (e) {
      setState(() {
        errorMessage = "$e";
      });
    }
  }

  void _sortPositionsByMac() {
    setState(() {
      positions.sort((a, b) => a.mac.compareTo(b.mac));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Position> filteredPositions = positions
        .where((element) =>
            element.mac.toLowerCase().startsWith(filter.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traggert Demo App'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              // Top row with filter and sort buttons
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SearchBar(
                    onChanged: (val) {
                      setState(() {
                        filter = val;
                      });
                    },
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    elevation: const WidgetStatePropertyAll<double>(1.0),
                    leading: const Icon(Icons.search),
                    trailing: [
                      Tooltip(
                        message: 'Sortiere nach Mac-Adresse',
                        child: IconButton(
                          onPressed: _sortPositionsByMac,
                          icon: const Icon(Icons.sort),
                        ),
                      ),
                    ],
                  )),
            const SizedBox(height: 16),
            if (filteredPositions.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("Keine Positionen gefunden"),
                ),
              )
            else
              // Result: List of positions
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchPositions,
                  child: ListView.builder(
                    itemCount: filteredPositions.length,
                    itemBuilder: (context, index) {
                      final position = filteredPositions[index];
                      return Card(
                        child: ListTile(
                          title: Text('Mac: ${position.mac}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Latitude: ${position.latitude}'),
                              Text('Longitude: ${position.longitude}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Reload data
            ElevatedButton(
              onPressed: _fetchPositions,
              child: Text("Daten erneut laden"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
