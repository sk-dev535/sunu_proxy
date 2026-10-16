import 'package:flutter/material.dart';

const Color vertPrincipal = Color(0xFF1B7A5C);

const List<String> categoriesCommerce = [
  'Alimentation',
  'Couture',
  'Coiffure',
  'Réparation',
  'Beauté',
  'Autres',
];

InputDecoration champ(String label, IconData icone) {
  final bordure = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icone, color: Colors.grey),
    filled: true,
    fillColor: Colors.white,
    border: bordure,
    enabledBorder: bordure,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: vertPrincipal, width: 2),
    ),
  );
}