import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  String? _selectedCategory;
  final List<String> _categories = [
    'Électronique',
    'Vêtements',
    'Maison',
    'Autres',
  ];

  final List<Color> _gradientColors = [
    Color(0xFF6A11CB),
    Color(0xFF2575FC),
  ];

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

    final uri = Uri.parse('http://185.98.136.156/products');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descController.text;
    request.fields['category'] = _selectedCategory!;
    request.fields['capacity'] = _capacityController.text;
    request.fields['price'] = _priceController.text;

    for (var file in _images) {
      request.files.add(
        await http.MultipartFile.fromPath('images', file.path),
      );
    }

    final response = await request.send();
    final success = response.statusCode == 200 || response.statusCode == 201;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Produit ajouté avec succès!'
            : 'Erreur lors de l\'ajout du produit.'),
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
                  _buildTextField(_titleController, 'Ex : Iphone 16 Pro'),
                  SizedBox(height: 12),
                  _buildTextField(
                    _descController,
                    'Ex : L’état, date de l’achat, garanties etc…',
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration('Catégorie de l’article…'),
                    hint: Text('Catégorie de l’article…'),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (val) =>
                        val == null ? 'Veuillez sélectionner une catégorie' : null,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(_capacityController, 'Ex : 256 GB'),
                  SizedBox(height: 12),
                  _buildTextField(
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
                    child: Text(
                      'Publiez',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white.withOpacity(0.2),
      filled: true,
      hintStyle: TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ce champ est requis' : null,
    );
  }
}