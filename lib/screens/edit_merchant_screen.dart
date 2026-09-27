import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['nom'] ?? '');
    _categoryController = TextEditingController(text: widget.initialData['categorie'] ?? '');
    _descriptionController = TextEditingController(text: widget.initialData['description'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['telephone'] ?? '');
  }

  Future<void> _updateMerchantData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance.collection('commerces').doc(widget.docId).update({
          'nom': _nameController.text.trim(),
          'categorie': _categoryController.text.trim(),
          'description': _descriptionController.text.trim(),
          'telephone': _phoneController.text.trim(),
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
    _categoryController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le Commerce'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom du commerce', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateMerchantData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer les modifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}