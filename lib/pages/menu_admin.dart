import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  MenuItem({required this.id, required this.name, required this.description, required this.price, required this.imageUrl});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
      };
}

class MenuAdminPage extends StatefulWidget {
  const MenuAdminPage({Key? key}) : super(key: key);

  @override
  State<MenuAdminPage> createState() => _MenuAdminPageState();
}

class _MenuAdminPageState extends State<MenuAdminPage> {
  final String _baseUrl = 'http://localhost:3000/menus';
  late Future<List<MenuItem>> _menuFuture;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  void _loadMenu() {
    setState(() {
      _menuFuture = _fetchMenuItems();
    });
  }

  Future<List<MenuItem>> _fetchMenuItems() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load menu');
    }
  }

  Future<void> _createMenuItem(MenuItem item) async {
    final response = await http.post(Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()));
    if (response.statusCode != 201) {
      throw Exception('Failed to create menu');
    }
    _loadMenu();
  }

  Future<void> _updateMenuItem(MenuItem item) async {
    final url = '$_baseUrl/${item.id}';
    final response = await http.put(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to update menu');
    }
    _loadMenu();
  }

  Future<void> _deleteMenuItem(String id) async {
    final url = '$_baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete menu');
    }
    _loadMenu();
  }

  void _showEditDialog({MenuItem? item}) {
    final isNew = item == null;
    final TextEditingController nameCtrl = TextEditingController(text: item?.name ?? '');
    final TextEditingController descCtrl = TextEditingController(text: item?.description ?? '');
    final TextEditingController priceCtrl = TextEditingController(text: item?.price.toString() ?? '');
    final TextEditingController imageCtrl = TextEditingController(text: item?.imageUrl ?? '');

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(isNew ? 'Tambah Menu' : 'Edit Menu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Harga'),
                  ),
                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: 'URL Gambar'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
              ElevatedButton(
                  onPressed: () async {
                    final double? price = double.tryParse(priceCtrl.text);
                    if (price == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harga tidak valid')));
                      return;
                    }
                    final newItem = MenuItem(
                        id: item?.id ?? '',
                        name: nameCtrl.text,
                        description: descCtrl.text,
                        price: price,
                        imageUrl: imageCtrl.text);
                    try {
                      if (isNew) {
                        await _createMenuItem(newItem);
                      } else {
                        await _updateMenuItem(newItem);
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: Text(isNew ? 'Tambah' : 'Simpan')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Menu Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadMenu()),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showEditDialog()),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.indigo.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<MenuItem>>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final menus = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Card(
                  color: Colors.white.withOpacity(0.85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: menu.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(menu.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.fastfood, size: 56),
                    title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\${menu.price.toStringAsFixed(2)} \n${menu.description}', maxLines: 2, overflow: TextOverflow.ellipsis),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showEditDialog(item: menu);
                        } else if (value == 'delete') {
                          try {
                            await _deleteMenuItem(menu.id);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
