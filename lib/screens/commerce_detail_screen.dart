import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/commerce.dart';

class CommerceDetailScreen extends StatelessWidget {
  final Commerce commerce;

  const CommerceDetailScreen({super.key, required this.commerce});

  Future<void> _appeler() async {
    final Uri uri = Uri(scheme: 'tel', path: commerce.telephone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _ouvrirWhatsApp() async {
    String numero = commerce.telephone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!numero.startsWith('221')) {
      numero = '221$numero';
    }
    final Uri uri = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const vertPrincipal = Color(0xFF1B7A5C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: Text(commerce.nom),
        backgroundColor: vertPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: vertPrincipal.withOpacity(0.12),
                child: Icon(Icons.storefront, size: 36, color: vertPrincipal),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                commerce.nom,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: vertPrincipal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  commerce.categorie,
                  style: TextStyle(color: vertPrincipal, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(commerce.description, style: const TextStyle(fontSize: 15)),
                    const Divider(height: 28),
                    const Text("Contact",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 18, color: vertPrincipal),
                        const SizedBox(width: 8),
                        Text(commerce.telephone, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _appeler,
                    icon: const Icon(Icons.phone),
                    label: const Text("Appeler"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertPrincipal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ouvrirWhatsApp,
                    icon: const Icon(Icons.chat),
                    label: const Text("WhatsApp"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}