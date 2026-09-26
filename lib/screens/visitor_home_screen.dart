import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commerce.dart';
import 'commerce_detail_screen.dart';
import 'package:geolocator/geolocator.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  String _recherche = '';
  String? _categorieSelectionnee;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _getPosition().then((pos) {
      setState(() {
        _position = pos;
      });
    });
  }

  Future<Position?> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SunuProxi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Rechercher un commerce...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _recherche = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('commerces').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucun commerce pour l'instant."));
                }

                final commerces = snapshot.data!.docs
                    .map((doc) => Commerce.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
                    .where((c) {
                      final matchTexte = c.nom.toLowerCase().contains(_recherche) ||
                          c.categorie.toLowerCase().contains(_recherche);
                      final matchCategorie = _categorieSelectionnee == null ||
                          c.categorie == _categorieSelectionnee;
                      return matchTexte && matchCategorie;
                    })
                    .toList();

                if (_position != null) {
                  commerces.sort((a, b) {
                    double distA = Geolocator.distanceBetween(
                        _position!.latitude, _position!.longitude, a.latitude, a.longitude);
                    double distB = Geolocator.distanceBetween(
                        _position!.latitude, _position!.longitude, b.latitude, b.longitude);
                    return distA.compareTo(distB);
                  });
                }

                if (commerces.isEmpty) {
                  return const Center(child: Text("Aucun résultat pour cette recherche."));
                }

                final categories = commerces.map((c) => c.categorie).toSet().toList();

                return Column(
                  children: [
                    if (categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          children: categories.map((cat) {
                            final selectionnee = _categorieSelectionnee == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: selectionnee,
                              onSelected: (bool value) {
                                setState(() {
                                  _categorieSelectionnee = value ? cat : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: commerces.length,
                        itemBuilder: (context, index) {
                          final commerce = commerces[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(commerce.nom),
                              subtitle: Text(commerce.categorie),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommerceDetailScreen(commerce: commerce),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}