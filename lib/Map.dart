import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model for Map
class MapInfo {
  final String uuid;
  final String name;
  final String? imageUrl;
  final String coordinates;
  final String? tacticalDescription;
  final String? listIcon;
  final String? stylizedBackgroundImage;
  final String? displayIcon;
  final String? premierBackgroundImage;
  final List<Callout> callouts;

  MapInfo({
    required this.uuid,
    required this.name,
    this.imageUrl,
    required this.coordinates,
    this.tacticalDescription,
    this.listIcon,
    this.stylizedBackgroundImage,
    this.displayIcon,
    this.premierBackgroundImage,
    required this.callouts,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) {
    var calloutsList = (json['callouts'] as List?)
        ?.map((callout) => Callout.fromJson(callout))
        .toList() ?? []; // Safely handle null callouts

    return MapInfo(
      uuid: json['uuid'] ?? 'Unknown', // Default to 'Unknown' if null
      name: json['displayName'] ?? 'Unknown', // Default to 'Unknown' if null
      imageUrl: json['splash'] ?? "", // Default to empty string if null
      coordinates: json['coordinates'] ?? 'No coordinates available', // Default if null
      tacticalDescription: json['tacticalDescription'] ?? "No Tactical Description", // Default if null
      listIcon: json['listViewIcon'] as String?, // Allow null if not present
      stylizedBackgroundImage: json['stylizedBackgroundImage'] as String?,
      displayIcon: json['displayIcon'] as String?,
      premierBackgroundImage: json['premierBackgroundImage'] as String?,
      callouts: calloutsList, // Safely handle null callouts
    );
  }
}

class Callout {
  final String regionName;
  final String superRegionName;
  final Location location;

  Callout({
    required this.regionName,
    required this.superRegionName,
    required this.location,
  });

  factory Callout.fromJson(Map<String, dynamic> json) {
    return Callout(
      regionName: json['regionName'] ?? "No Region Name", // Default if null
      superRegionName: json['superRegionName'] ?? "No Super Region", // Default if null
      location: Location.fromJson(json['location'] ?? {}), // Safely handle null location
    );
  }
}

class Location {
  final double x;
  final double y;

  Location({
    required this.x,
    required this.y,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      x: (json['x'] ?? 0.0).toDouble(), // Safe to default to 0.0 if null
      y: (json['y'] ?? 0.0).toDouble(), // Safe to default to 0.0 if null
    );
  }
}

// Fetch data from API
Future<List<MapInfo>> fetchMaps() async {
  final url = Uri.parse('https://valorant-api.com/v1/maps');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((json) => MapInfo.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load maps');
  }
}

// Main Widget
class MapListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Maps',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MapList(),
    );
  }
}

// Map List Widget
class MapList extends StatefulWidget {
  @override
  _MapListState createState() => _MapListState();
}

class _MapListState extends State<MapList> {
  late Future<List<MapInfo>> futureMaps;

  @override
  void initState() {
    super.initState();
    futureMaps = fetchMaps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorant Maps'),
      ),
      body: FutureBuilder<List<MapInfo>>(
        future: futureMaps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final maps = snapshot.data!;
            return ListView.builder(
              itemCount: maps.length,
              itemBuilder: (context, index) {
                final map = maps[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: map.listIcon != null
                        ? Image.network(
                            map.listIcon!,
                            width: 80,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.map),
                          )
                        : Icon(Icons.map),
                    title: Text(map.name),
                    subtitle: Text('Coordinates: ${map.coordinates}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapDetail(map: map),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

// Map Detail Widget
class MapDetail extends StatelessWidget {
  final MapInfo map;

  const MapDetail({Key? key, required this.map}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(map.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: map.displayIcon != null
                    ? Image.network(
                        map.displayIcon!,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.map, size: 100),
                      )
                    : Icon(Icons.map, size: 100),
              ),
              SizedBox(height: 20),
              Text(
                map.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Coordinates: ${map.coordinates}',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              if (map.tacticalDescription != null)
                Text(
                  'Tactical Description: ${map.tacticalDescription}',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              Text(
                'Callouts:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...map.callouts.map((callout) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${callout.regionName} (Super Region: ${callout.superRegionName}) - Location: (${callout.location.x}, ${callout.location.y})',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
