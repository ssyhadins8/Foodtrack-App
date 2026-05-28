import 'package:flutter/material.dart';

/// A simple dialog that allows the user to select a kantin (canteen).
///
/// This is a placeholder implementation. You can replace the sample list
/// with the actual kantin data from your backend or Firestore collection.
class KantinSelectorDialog extends StatelessWidget {
  const KantinSelectorDialog({Key? key}) : super(key: key);

  static const List<String> _sampleKantins = [
    'Kantin A',
    'Kantin B',
    'Kantin C',
    'Kantin D',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Kantin'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _sampleKantins.length,
          itemBuilder: (context, index) {
            final kantin = _sampleKantins[index];
            return ListTile(
              title: Text(kantin),
              onTap: () => Navigator.of(context).pop(kantin),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
