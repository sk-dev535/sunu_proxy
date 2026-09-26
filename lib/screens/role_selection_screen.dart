import 'package:flutter/material.dart';
import 'visitor_home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SunuProxi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bienvenue sur SunuProxi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Comment souhaitez-vous continuer ?",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VisitorHomeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Je suis un Visiteur"),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO : remplacer par l'écran de connexion Commerçant
                    // une fois le travail du binôme fusionné
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Écran Commerçant à venir")),
                    );
                  },
                  icon: const Icon(Icons.store),
                  label: const Text("Je suis un Commerçant"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}