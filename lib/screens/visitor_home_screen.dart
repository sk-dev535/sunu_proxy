import 'package:flutter/material.dart';
import '../models/commerce.dart';

class VisitorHomeScreen extends StatelessWidget {
  const VisitorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Donnees factices, juste pour construire l'interface
    final List<Commerce> commerces = [
      Commerce(nom: "Chez Fatou", categorie: "Couturière", description: "Confection sur mesure", telephone: "+221771234567"),
      Commerce(nom: "Garage Modou", categorie: "Réparateur", description: "Réparation auto et moto", telephone: "+221781234567"),
      Commerce(nom: "Pâtisserie Awa", categorie: "Pâtissier", description: "Gâteaux et pâtisseries", telephone: "+221701234567"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('SunuProxi')),
      body: ListView.builder(
        itemCount: commerces.length,
        itemBuilder: (context, index) {
          final commerce = commerces[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(commerce.nom),
              subtitle: Text(commerce.categorie),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}