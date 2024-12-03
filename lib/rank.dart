import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model untuk Competitive Tier
class CompetitiveTier {
  final int tierId;
  final String? tierName;
  final String? division;
  final String? divisionName;
  final String? color;
  final String? backgroundColor;
  final String? smallIcon;
  final String? largeIcon;

  CompetitiveTier({
    required this.tierId,
    this.tierName,
    this.division,
    this.divisionName,
    this.color,
    this.backgroundColor,
    this.smallIcon,
    this.largeIcon,
  });

  factory CompetitiveTier.fromJson(Map<String, dynamic> json) {
    return CompetitiveTier(
      tierId: json['tier'] ?? 0,
      tierName: json['tierName'],
      division: json['division'],
      divisionName: json['divisionName'],
      color: json['color'],
      backgroundColor: json['backgroundColor'],
      smallIcon: json['smallIcon'],
      largeIcon: json['largeIcon'],
    );
  }
}

class CompetitiveTiers {
  final String uuid;
  final String name;
  final List<CompetitiveTier> tiers;

  CompetitiveTiers({
    required this.uuid,
    required this.name,
    required this.tiers,
  });

  factory CompetitiveTiers.fromJson(Map<String, dynamic> json) {
    var tiersList = (json['tiers'] as List)
        .map((tier) => CompetitiveTier.fromJson(tier))
        .toList();
    return CompetitiveTiers(
      uuid: json['uuid'] ?? 'Unknown',
      name: json['assetObjectName'] ?? 'Unknown',
      tiers: tiersList,
    );
  }
}

// Fetching data Competitive Tiers API
Future<List<CompetitiveTiers>> fetchCompetitiveTiers() async {
  final url = Uri.parse('https://valorant-api.com/v1/competitivetiers');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((json) => CompetitiveTiers.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load competitive tiers');
  }
}

// Widget Utama
class CompetitiveTierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Competitive Tiers',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CompetitiveTierList(),
    );
  }
}

// Halaman List Competitive Tiers
class CompetitiveTierList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Competitive Tiers'),
      ),
      body: FutureBuilder<List<CompetitiveTiers>>(
        future: fetchCompetitiveTiers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final tiers = snapshot.data!;
            return ListView.builder(
              itemCount: tiers.length,
              itemBuilder: (context, index) {
                final tierGroup = tiers[index];
                return ExpansionTile(
                  title: Text(tierGroup.name),
                  children: tierGroup.tiers.map((tier) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: tier.largeIcon != null
                          ? Image.network(tier.largeIcon!, width: 60, height: 60, fit: BoxFit.cover)
                          : Icon(Icons.star, size: 40), // Use Icons.star here instead of Icons.trophy
                      title: Text(
                        tier.tierName ?? 'No Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Division: ${tier.divisionName ?? 'N/A'}'),
                          SizedBox(height: 5),
                          Text('Color: ${tier.color ?? 'Unknown'}'),
                          SizedBox(height: 5),
                          Text('Background Color: ${tier.backgroundColor ?? 'Unknown'}'),
                        ],
                      ),
                      trailing: tier.smallIcon != null
                          ? Image.network(
                              tier.smallIcon!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
            );
          } else {
            return Center(child: Text('No competitive tiers available'));
          }
        },
      ),
    );
  }
}
