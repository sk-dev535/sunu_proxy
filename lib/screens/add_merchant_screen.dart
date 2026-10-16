import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/form_style.dart';
import '../widgets/time_field.dart';

class AddMerchantScreen extends StatefulWidget {
  const AddMerchantScreen({super.key});

  @override
  State<AddMerchantScreen> createState() => _AddMerchantScreenState();
}

class _AddMerchantScreenState extends State<AddMerchantScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _openController = TextEditingController();
  final TextEditingController _closeController = TextEditingController();
  String? _categorie;

  bool _isLoading = false;

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

  Future<void> _submitMerchantData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        final position = await _getPosition();

        await FirebaseFirestore.instance.collection('commerces').add({
          'nom': _nameController.text.trim(),
          'categorie': _categorie,
          'description': _descriptionController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'heureOuverture': _openController.text,
          'heureFermeture': _closeController.text,
          'latitude': position?.latitude ?? 0.0,
          'longitude': position?.longitude ?? 0.0,
          'idCommercant': user?.uid ?? 'unknown',
          'createdAt': Timestamp.now(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commerce ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout : $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _openController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text('Créer mon profil commerçant'),
        backgroundColor: const Color(0xFFF5F5F0),
        foregroundColor: const Color(0xFF0F4D3A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: vertPrincipal,
                  child: Icon(Icons.storefront, size: 44, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: champ('Nom du commerce', Icons.store),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Veuillez entrer le nom du commerce'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categorie,
                decoration: champ('Catégorie', Icons.category),
                items: categoriesCommerce
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => _categorie = v,
                validator: (v) =>
                    v == null ? 'Veuillez choisir une catégorie' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: champ('Description', Icons.description),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Veuillez entrer une description'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: champ('Contact (téléphone / WhatsApp)', Icons.phone),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Veuillez entrer un numéro de téléphone'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TimeField(
                          controller: _openController, label: 'Ouverture')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TimeField(
                          controller: _closeController, label: 'Fermeture')),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Votre position actuelle sera enregistrée automatiquement comme emplacement du commerce.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMerchantData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Créer mon profil',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}