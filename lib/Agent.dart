import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model untuk agen
class Agent {
  final String name;
  final String description;
  final String role;
  final List<Ability> abilities;
  final String imageUrl;
  final String fullPortraitUrl;
  final String backgroundUrl;

  Agent({
    required this.name,
    required this.description,
    required this.role,
    required this.abilities,
    required this.imageUrl,
    required this.fullPortraitUrl,
    required this.backgroundUrl,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      name: json['displayName'] ?? 'Unknown',
      description: json['description'] ?? 'No description available',
      role: json['role'] != null ? json['role']['displayName'] : 'Unknown',
      abilities: (json['abilities'] as List)
          .map((ability) => Ability.fromJson(ability))
          .toList(),
      imageUrl: json['displayIcon'] ?? '',
      fullPortraitUrl: json['fullPortrait'] ?? '',
      backgroundUrl: json['background'] ?? '',
    );
  }
}

// Model untuk Ability
class Ability {
  final String name;
  final String description;
  final String iconUrl;

  Ability({
    required this.name,
    required this.description,
    required this.iconUrl,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['displayName'] ?? 'Unknown',
      description: json['description'] ?? 'No description available',
      iconUrl: json['displayIcon'] ?? '',
    );
  }
}

// Fungsi untuk fetch data dari API
Future<List<Agent>> fetchAgents() async {
  final url = Uri.parse('https://valorant-api.com/v1/agents');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List).map((json) => Agent.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load agents');
  }
}

// Widget utama
class AgentListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Agents',
      theme: ThemeData(primarySwatch: Colors.red),
      home: AgentList(),
    );
  }
}

// Widget untuk menampilkan daftar agen
class AgentList extends StatefulWidget {
  @override
  _AgentListState createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  late Future<List<Agent>> futureAgents;

  @override
  void initState() {
    super.initState();
    futureAgents = fetchAgents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorant Agents'),
      ),
      body: FutureBuilder<List<Agent>>(
        future: futureAgents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final agents = snapshot.data!;
            return ListView.builder(
              itemCount: agents.length,
              itemBuilder: (context, index) {
                final agent = agents[index];
                return ListTile(
                  leading: agent.imageUrl.isNotEmpty
                      ? Image.network(agent.imageUrl, width: 50, height: 50)
                      : Icon(Icons.image_not_supported),
                  title: Text(agent.name),
                  subtitle: Text(agent.role),
                  onTap: () {
                    // Navigasi ke halaman detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgentDetail(agent: agent),
                      ),
                    );
                  },
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

// Halaman detail agen
class AgentDetail extends StatelessWidget {
  final Agent agent;

  const AgentDetail({Key? key, required this.agent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(agent.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: agent.fullPortraitUrl.isNotEmpty
                    ? Image.network(agent.fullPortraitUrl, height: 200)
                    : Icon(Icons.image_not_supported, size: 100),
              ),
              SizedBox(height: 20),
              Text(
                agent.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Role: ${agent.role}',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              Text(
                agent.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Abilities:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...agent.abilities.map((ability) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        if (ability.iconUrl.isNotEmpty)
                          Image.network(
                            ability.iconUrl,
                            width: 40,
                            height: 40,
                          ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ability.name,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(ability.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
