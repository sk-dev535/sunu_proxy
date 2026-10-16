import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/form_style.dart';
import '../widgets/time_field.dart';

class EditMerchantScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditMerchantScreen({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<EditMerchantScreen> createState() => _EditMerchantScreenState();
}

class _EditMerchantScreenState extends State<EditMerchantScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _openController;
  late final TextEditingController _closeController;
  String? _categorie;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialData['nom'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialData['description'] ?? '');
    _phoneController =
        TextEditingController(text: widget.initialData['telephone'] ?? '');
    _openController =
        TextEditingController(text: widget.initialData['heureOuverture'] ?? '');
    _closeController =
        TextEditingController(text: widget.initialData['heureFermeture'] ?? '');

    // Si l'ancienne catégorie n'est pas dans la liste, le commerçant doit en choisir une
    final cat = widget.initialData['categorie'] ?? '';
    _categorie = categoriesCommerce.contains(cat) ? cat : null;
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

  Future<void> _updatePosition() async {
    final position = await _getPosition();
    if (position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Impossible de récupérer votre position. Vérifiez que la localisation est activée."),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('commerces')
          .doc(widget.docId)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Position mise à jour !"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateMerchantData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('commerces')
            .doc(widget.docId)
            .update({
          'nom': _nameController.text.trim(),
          'categorie': _categorie,
          'description': _descriptionController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'heureOuverture': _openController.text,
          'heureFermeture': _closeController.text,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commerce mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour : $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Modifier ma fiche'),
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
              TextFormField(
                controller: _nameController,
                decoration: champ('Nom du commerce', Icons.store),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categorie,
                decoration: champ('Catégorie', Icons.category),
                items: categoriesCommerce
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => _categorie = v,
                validator: (v) => v == null ? 'Choisissez une catégorie' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: champ('Description', Icons.description),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: champ('Contact (téléphone / WhatsApp)', Icons.phone),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _updatePosition,
                icon: const Icon(Icons.my_location),
                label: const Text("Mettre à jour ma position"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: vertPrincipal,
                  side: const BorderSide(color: vertPrincipal),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateMerchantData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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