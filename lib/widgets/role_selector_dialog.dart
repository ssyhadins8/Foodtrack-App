import 'package:flutter/material.dart';

class RoleSelectorDialog extends StatelessWidget {
  const RoleSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selected = 'pembeli';
    return AlertDialog(
      title: const Text('Pilih Peran'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('🛒 Pembeli'),
                value: 'pembeli',
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v!),
              ),
              RadioListTile<String>(
                title: const Text('🏪 Pedagang'),
                value: 'pedagang',
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v!),
              ),
              RadioListTile<String>(
                title: const Text('🔑 Admin'),
                value: 'admin',
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v!),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selected),
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}
