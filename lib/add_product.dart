import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['ID'] as String, // ou 'id' selon ton JSON
      name: json['Name'] as String, // ou 'name'
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  List<XFile> _images = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final uri = Uri.parse('http://185.98.136.156:8080/categories');
    try {
      final res = await http.get(
        uri,
        headers: {'Accept-Charset': 'utf-8'}, // Ajoutez ce header
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          _categories =
              data
                  .map(
                    (json) => Category.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();
          _loadingCategories = false;
        });
      } else {
        throw Exception('Erreur ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _loadingCategories = false);
      // Gère l’erreur ici (Snackbar, log…)
    }
  }

  final List<Color> _gradientColors = [Color(0xFF6A11CB), Color(0xFF2575FC)];

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked != null && picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('http://185.98.136.156:8080/products');
    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_username');

    // request.headers['Content-Type'] = 'multipart/form-data';
    if (username != null) {
      request.headers['X-User-Username'] = username;
    }

    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descController.text;
    request.fields['category'] = _selectedCategoryId!;
    request.fields['capacity'] = _capacityController.text;
    request.fields['price'] = _priceController.text;

    for (var file in _images) {
      request.files.add(await http.MultipartFile.fromPath('images', file.path));
    }

    final response = await request.send();
    final success = response.statusCode == 200 || response.statusCode == 201;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Produit ajouté avec succès!'
              : 'Erreur lors de l\'ajout du produit.',
        ),
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ajoutez un article',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          // Thumbnails with delete buttons
                          for (var i = 0; i < _images.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_images[i].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(i),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Add more button
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white70),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white70,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(label: "Titre", _titleController, 'Ex : Iphone 16 Pro'),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: "Décris ton article",
                    _descController,
                    'Ex : L’état, date de l’achat, garanties etc…',
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration('Catégorie de l’article…'),
                    hint: Text('Catégorie de l’article…'),
                    items:
                        _categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(
                                  cat.name,
                                  style: GoogleFonts.notoSans(
                                    // Police qui supporte bien le français
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() => _selectedCategoryId = val),
                    validator:
                        (val) =>
                            val == null
                                ? 'Veuillez sélectionner une catégorie'
                                : null,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(label: "Capacité", _capacityController, 'Ex : 256 GB'),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: "Prix sans frais de port",
                    _priceController,
                    'Prix',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Publiez', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? label}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      fillColor: Colors.white.withOpacity(0.2),
      filled: true,
      hintStyle: TextStyle(color: Colors.white70),
      labelStyle: TextStyle(color: Colors.white), // Label text style
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    String? label, // New label parameter
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        hint,
        label: label,
      ), // Pass label to decoration
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Ce champ est requis' : null,
    );
  }
}
