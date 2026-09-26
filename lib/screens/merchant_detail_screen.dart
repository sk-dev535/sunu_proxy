import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> merchantData;

  const MerchantDetailScreen({
    super.key,
    required this.merchantData,
  });

  // Fonction pour lancer un appel téléphonique
  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Impossible de lancer l\'appel';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  // Fonction pour lancer WhatsApp
  Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir WhatsApp';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = merchantData['phone'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(merchantData['merchantName'] ?? 'Détails du commerce'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.shade100,
                child: const Icon(Icons.store, size: 40, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                merchantData['merchantName'] ?? 'Nom non disponible',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Carte des informations
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.category, 'Catégorie', merchantData['category']),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.location_on, 'Quartier', merchantData['quartier']),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.phone, 'Téléphone', phone),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.description, 'Description', merchantData['description']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Boutons de contact (Appel et WhatsApp)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: phone.isEmpty ? null : () => _makePhoneCall(phone, context),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Appeler', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: phone.isEmpty ? null : () => _openWhatsApp(phone, context),
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'Non renseigné',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}