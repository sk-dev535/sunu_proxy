import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/commerce.dart';
import 'add_merchant_screen.dart';
import 'edit_merchant_screen.dart';
import 'commerce_detail_screen.dart';
import 'role_selection_screen.dart';

const _vert = Color(0xFF1B7A5C);
const _vertFonce = Color(0xFF0F4D3A);
const _fond = Color(0xFFF5F5F0);

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  String _prenom() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final debut = email.split('@').first;
    if (debut.isEmpty) return '';
    return debut[0].toUpperCase() + debut.substring(1);
  }

  Future<void> _deconnexion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteMerchant(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce commerce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('commerces')
            .doc(docId)
            .delete();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commerce supprimé avec succès')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')),
        );
      }
    }
  }

  Widget _badge(bool? ouvert) {
    final texte = ouvert == null ? 'En ligne' : (ouvert ? 'Ouvert' : 'Fermé');
    final couleur = ouvert == false ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _tuile({
    required IconData icone,
    required Color couleur,
    required String titre,
    required String sousTitre,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: couleur.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icone, color: couleur),
        ),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sousTitre, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _blocCommerce(
      BuildContext context, String docId, Map<String, dynamic> data) {
    final commerce = Commerce.fromFirestore(docId, data);

    return Column(
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _vert.withOpacity(0.12),
                  child: const Icon(Icons.storefront, color: _vert, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mon commerce',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        commerce.nom,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(commerce.categorie,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                _badge(commerce.estOuvert),
              ],
            ),
          ),
        ),
        _tuile(
          icone: Icons.article_outlined,
          couleur: _vert,
          titre: 'Voir ma fiche',
          sousTitre: 'Consulter votre profil public',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommerceDetailScreen(commerce: commerce),
              ),
            );
          },
        ),
        _tuile(
          icone: Icons.edit,
          couleur: Colors.blue,
          titre: 'Modifier ma fiche',
          sousTitre: 'Mettre à jour vos informations',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditMerchantScreen(docId: docId, initialData: data),
              ),
            );
          },
        ),
        _tuile(
          icone: Icons.delete_outline,
          couleur: Colors.red,
          titre: 'Supprimer mon profil',
          sousTitre: 'Supprimer définitivement ce commerce',
          onTap: () => _deleteMerchant(context, docId),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final prenom = _prenom();

    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        title: const Text('Espace commerçant',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _fond,
        foregroundColor: _vertFonce,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => _deconnexion(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commerces')
            .where('idCommercant', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Text(
                prenom.isEmpty ? 'Bonjour' : 'Bonjour, $prenom',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Gérez votre commerce facilement',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 18),
              if (docs.isEmpty)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Vous n'avez pas encore de commerce. Ajoutez-le pour que les visiteurs puissent vous trouver.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ...docs.map((d) => _blocCommerce(
                  context, d.id, d.data() as Map<String, dynamic>)),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMerchantScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(docs.isEmpty
                    ? 'Ajouter mon commerce'
                    : 'Ajouter un autre commerce'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vert,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}