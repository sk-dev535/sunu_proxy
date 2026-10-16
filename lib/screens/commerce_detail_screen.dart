import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/commerce.dart';

class CommerceDetailScreen extends StatelessWidget {
  final Commerce commerce;

  const CommerceDetailScreen({super.key, required this.commerce});

  static const vertPrincipal = Color(0xFF1B7A5C);

  CollectionReference get _avisRef => FirebaseFirestore.instance
      .collection('commerces')
      .doc(commerce.id)
      .collection('avis');

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

  Future<void> _ouvrirCarte() async {
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${commerce.latitude},${commerce.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _donnerAvis(BuildContext context) async {
    int note = 0;
    final nomCtrl = TextEditingController();
    final commentCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Donner mon avis'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < note ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setStateDialog(() => note = i + 1),
                    );
                  }),
                ),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Votre prénom (facultatif)'),
                ),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(labelText: 'Votre commentaire'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: note == 0
                  ? null
                  : () async {
                      try {
                        await _avisRef.add({
                          'note': note,
                          'nom': nomCtrl.text.trim(),
                          'commentaire': commentCtrl.text.trim(),
                          'createdAt': Timestamp.now(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Erreur : $e')),
                          );
                        }
                      }
                    },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: Text(commerce.nom),
        backgroundColor: vertPrincipal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _avisRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final notes = docs
              .map((d) => ((d.data() as Map<String, dynamic>)['note'] ?? 0) as num)
              .toList();
          final moyenne =
              notes.isEmpty ? 0.0 : notes.reduce((a, b) => a + b) / notes.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: vertPrincipal.withOpacity(0.12),
                    child: const Icon(Icons.storefront, size: 36, color: vertPrincipal),
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
                      style: const TextStyle(
                          color: vertPrincipal, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: notes.isEmpty
                      ? const Text("Pas encore d'avis",
                          style: TextStyle(color: Colors.grey))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${moyenne.toStringAsFixed(1).replaceAll('.', ',')} (${notes.length} avis)',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
                if (commerce.estOuvert != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      commerce.estOuvert!
                          ? 'Ouvert • ${commerce.heureOuverture} - ${commerce.heureFermeture}'
                          : 'Fermé • ouvre à ${commerce.heureOuverture}',
                      style: TextStyle(
                        color: commerce.estOuvert! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(commerce.description, style: const TextStyle(fontSize: 15)),
                        const Divider(height: 28),
                        const Text("Contact",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 18, color: vertPrincipal),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: (commerce.latitude == 0 && commerce.longitude == 0)
                        ? null
                        : _ouvrirCarte,
                    icon: const Icon(Icons.location_on),
                    label: const Text("Voir sur la carte"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: vertPrincipal,
                      side: const BorderSide(color: vertPrincipal),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Avis",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _donnerAvis(context),
                      icon: const Icon(Icons.rate_review),
                      label: const Text("Donner mon avis"),
                    ),
                  ],
                ),
                if (docs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Soyez le premier à donner votre avis.",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ...docs.take(10).map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final n = (data['note'] ?? 0) as int;
                  final nom = (data['nom'] ?? '') as String;
                  final comm = (data['commentaire'] ?? '') as String;
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < n ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(nom.isEmpty ? 'Anonyme' : nom,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (comm.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(comm),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}