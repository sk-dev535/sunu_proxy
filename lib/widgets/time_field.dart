import 'package:flutter/material.dart';
import 'form_style.dart';

class TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const TimeField({super.key, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: champ(label, Icons.access_time),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 8, minute: 0),
        );
        if (t != null) {
          controller.text =
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        }
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
    );
  }
}