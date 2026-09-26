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
  // Si le numéro ne commence pas déjà par l'indicatif Sénégal (221), on l'ajoute
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
    return Scaffold(
      appBar: AppBar(title: Text(commerce.nom)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commerce.categorie,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(commerce.description),
            const SizedBox(height: 16),
            const Text("Téléphone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(commerce.telephone),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _appeler,
                    icon: const Icon(Icons.phone),
                    label: const Text("Appeler"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _ouvrirWhatsApp,
                    icon: const Icon(Icons.chat),
                    label: const Text("WhatsApp"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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