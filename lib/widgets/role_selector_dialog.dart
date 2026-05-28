import 'package:flutter/material.dart';
import 'package:foodtrack/theme/app_colors.dart';

class RoleSelectorDialog extends StatelessWidget {
  const RoleSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _selected = 'pembeli';
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
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
              ),
              RadioListTile<String>(
                title: const Text('🏪 Pedagang'),
                value: 'pedagang',
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
              ),
              RadioListTile<String>(
                title: const Text('🔑 Admin'),
                value: 'admin',
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
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
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}
