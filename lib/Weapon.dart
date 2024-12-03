import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model untuk Weapon
class Weapon {
  final String name;
  final String category;
  final String? imageUrl;
  final WeaponStats? weaponStats;
  final ShopData? shopData;

  Weapon({
    required this.name,
    required this.category,
    this.imageUrl,
    this.weaponStats,
    this.shopData,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      name: json['displayName'] ?? 'Unknown',
      category: json['category']?.split("::").last ?? 'Unknown',
      imageUrl: json['displayIcon'],
      weaponStats: json['weaponStats'] != null
          ? WeaponStats.fromJson(json['weaponStats'])
          : null,
      shopData: json['shopData'] != null ? ShopData.fromJson(json['shopData']) : null,
    );
  }
}

class WeaponStats {
  final double fireRate;
  final int magazineSize;
  final double equipTimeSeconds;
  final double reloadTimeSeconds;
  final List<DamageRange> damageRanges;

  WeaponStats({
    required this.fireRate,
    required this.magazineSize,
    required this.equipTimeSeconds,
    required this.reloadTimeSeconds,
    required this.damageRanges,
  });

  factory WeaponStats.fromJson(Map<String, dynamic> json) {
    return WeaponStats(
      fireRate: json['fireRate']?.toDouble() ?? 0.0,
      magazineSize: json['magazineSize'] ?? 0,
      equipTimeSeconds: json['equipTimeSeconds']?.toDouble() ?? 0.0,
      reloadTimeSeconds: json['reloadTimeSeconds']?.toDouble() ?? 0.0,
      damageRanges: (json['damageRanges'] as List)
          .map((range) => DamageRange.fromJson(range))
          .toList(),
    );
  }
}

class DamageRange {
  final int rangeStartMeters;
  final int rangeEndMeters;
  final double headDamage;
  final double bodyDamage;
  final double legDamage;

  DamageRange({
    required this.rangeStartMeters,
    required this.rangeEndMeters,
    required this.headDamage,
    required this.bodyDamage,
    required this.legDamage,
  });

  factory DamageRange.fromJson(Map<String, dynamic> json) {
    return DamageRange(
      rangeStartMeters: json['rangeStartMeters'] ?? 0,
      rangeEndMeters: json['rangeEndMeters'] ?? 0,
      headDamage: json['headDamage']?.toDouble() ?? 0.0,
      bodyDamage: json['bodyDamage']?.toDouble() ?? 0.0,
      legDamage: json['legDamage']?.toDouble() ?? 0.0,
    );
  }
}

class ShopData {
  final int cost;
  final String categoryText;

  ShopData({
    required this.cost,
    required this.categoryText,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      cost: json['cost'] ?? 0,
      categoryText: json['categoryText'] ?? 'Unknown',
    );
  }
}

// Fungsi untuk fetch data dari API
Future<List<Weapon>> fetchWeapons() async {
  final url = Uri.parse('https://valorant-api.com/v1/weapons');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List).map((json) => Weapon.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load weapons');
  }
}

// Widget utama
class WeaponListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Weapons',
      theme: ThemeData(primarySwatch: Colors.red),
      home: WeaponList(),
    );
  }
}

// Widget untuk menampilkan daftar senjata
class WeaponList extends StatefulWidget {
  @override
  _WeaponListState createState() => _WeaponListState();
}

class _WeaponListState extends State<WeaponList> {
  late Future<List<Weapon>> futureWeapons;

  @override
  void initState() {
    super.initState();
    futureWeapons = fetchWeapons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorant Weapons'),
      ),
      body: FutureBuilder<List<Weapon>>(
        future: futureWeapons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final weapons = snapshot.data!;
            return ListView.builder(
              itemCount: weapons.length,
              itemBuilder: (context, index) {
                final weapon = weapons[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: weapon.imageUrl != null
                        ? Image.network(
                            weapon.imageUrl!,
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) => Icon(Icons.error),
                          )
                        : Icon(Icons.error),
                    title: Text(weapon.name),
                    subtitle: Text('${weapon.category} | ${weapon.shopData?.cost ?? 0} Credits'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeaponDetail(weapon: weapon),
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

// Halaman detail senjata
class WeaponDetail extends StatelessWidget {
  final Weapon weapon;

  const WeaponDetail({Key? key, required this.weapon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weapon.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: weapon.imageUrl != null
                    ? Image.network(
                        weapon.imageUrl!,
                        height: 200,
                        errorBuilder: (_, __, ___) => Icon(Icons.error, size: 100),
                      )
                    : Icon(Icons.error, size: 100),
              ),
              SizedBox(height: 20),
              Text(
                weapon.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Category: ${weapon.category}'),
              SizedBox(height: 10),
              Text('Cost: ${weapon.shopData?.cost ?? 0} Credits'),
              SizedBox(height: 20),
              weapon.weaponStats != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weapon Stats:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Fire Rate: ${weapon.weaponStats?.fireRate}'),
                        Text('Magazine Size: ${weapon.weaponStats?.magazineSize}'),
                        Text('Reload Time: ${weapon.weaponStats?.reloadTimeSeconds}s'),
                        SizedBox(height: 10),
                        Text(
                          'Damage Ranges:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ...weapon.weaponStats!.damageRanges.map((range) {
                          return Text(
                              'Range ${range.rangeStartMeters}-${range.rangeEndMeters}m: Head ${range.headDamage}, Body ${range.bodyDamage}, Leg ${range.legDamage}');
                        }),
                      ],
                    )
                  : Text('No stats available for this weapon.'),
            ],
          ),
        ),
      ),
    );
  }
}