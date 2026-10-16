import 'package:flutter/material.dart';
import 'visitor_home_screen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const vert = Color(0xFF1B7A5C);
    const vertFonce = Color(0xFF0F4D3A);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F1E8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo : pin de localisation + vitrine
                Stack(
                  alignment: Alignment.center,
                  children: const [
                    Icon(Icons.location_on, size: 120, color: vert),
                    Padding(
                      padding: EdgeInsets.only(bottom: 22),
                      child: Icon(Icons.storefront, size: 44, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Sunu', style: TextStyle(color: vertFonce)),
                      TextSpan(text: 'Proxi', style: TextStyle(color: vert)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Les commerces de proximité\nà portée de main',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
                ),
                const Spacer(flex: 2),
                // Petit décor en icônes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.park, size: 44, color: vert.withOpacity(0.35)),
                    const SizedBox(width: 8),
                    Icon(Icons.storefront, size: 64, color: vert.withOpacity(0.55)),
                    const SizedBox(width: 8),
                    Icon(Icons.store, size: 52, color: vert.withOpacity(0.4)),
                    const SizedBox(width: 8),
                    Icon(Icons.park, size: 36, color: vert.withOpacity(0.3)),
                  ],
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VisitorHomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vert,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Commencer',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Se connecter (espace commerçant)',
                    style: TextStyle(color: vert, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}