import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Product {
  final String id;
  final List<String> imageUrls;
  final String title;
  final String category;
  final String description;
  final double price;
  final String condition;
  final String sellerId;

  Product({
    required this.id,
    required this.imageUrls,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.condition,
    required this.sellerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'http://185.98.136.156:8080/';
    
    // Handle category - it could be String or Map
    dynamic categoryValue = json['category'];
    String category = '';
    if (categoryValue is String) {
      category = categoryValue;
    } else if (categoryValue is Map) {
      category = categoryValue['name']?.toString() ?? 'Sans catégorie';
    }

    // Handle images safely
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final imageUrls = imagesJson
        .map<String?>((img) {
          final url = img['ImageURL'] as String?;
          return url != null ? baseUrl + url : null;
        })
        .whereType<String>()
        .toList();
    debugPrint('Images URLs: $imageUrls');
    return Product(
      id: json['ID']?.toString() ?? '',
      imageUrls: imageUrls,
      title: json['title']?.toString() ?? 'Titre inconnu',
      category: category,
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      condition: json['condition']?.toString() ?? 'Inconnu',
      sellerId: json['seller_id']?.toString() ?? '',
    );
  }
}

class ProductImage {
  final String id;
  final String imageUrl;

  ProductImage({required this.id, required this.imageUrl});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    final baseUrl = 'http://185.98.136.156:8080/';
    return ProductImage(
      id: json['ID'] as String,
      imageUrl: baseUrl + (json['ImageURL'] as String),
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _brands = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://185.98.136.156:8080/products'),
    );
    if (response.statusCode == 200) {
      print('Réponse brute : ${response.body}');
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> productJson = json.decode(response.body);
      print('Données décodées : $productJson');

      setState(() {
        _products =
            productJson.map((jsonItem) => Product.fromJson(jsonItem)).toList();
            
        _filteredProducts = _products;
        _brands = [
          'Logitech',
          'Sony',
          'Nokia',
          'Apple',
          'Samsung',
          'Asus',
          'LG',
          'Razer',
          'Microsoft',
          'Bose',
          'JBL',
          'Canon',
          'Nikon',
          'HP',
          'Dell',
        ];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _filterProducts(String query) {
    final filtered =
        _products.where((product) {
          final titleLower = product.title.toLowerCase();
          final descriptionLower = product.description.toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) ||
              descriptionLower.contains(searchLower);
        }).toList();

    setState(() {
      _searchQuery = query;
      _filteredProducts = filtered;
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Accueil',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              _buildIconButton(Icons.favorite_border),
              SizedBox(width: 12),
              _buildIconButton(Icons.notifications_none),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      padding: EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: _filterProducts,
        style: TextStyle(
          // Use a paint shader to apply the gradient
          foreground:
              Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF2E2F89), Color(0xFF30C8A5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher des objets ou des membres',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF2E2F89), Color(0xFF30C8A5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: const Icon(Icons.search, color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Using the provided _buildProductCard widget
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/product/:id', arguments: product.id);
      },
      child: Container(
        width:
            159, // This width might be overridden by carousel's viewport logic
        // height: 225, // Height is managed by CarouselOptions.height for the overall carousel
        margin: const EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 8.0,
        ), // Adjusted margin slightly
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Ensure children fill width
          children: [
            // Image area
            Expanded(
              // Use Expanded to allow image to take available vertical space
              flex: 3, // Adjust flex factor as needed
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrls.isNotEmpty 
                      ? product.imageUrls[0] 
                      : 'https://via.placeholder.com/150',

                    fit:
                        BoxFit
                            .cover, // Cover ensures the image fills the space, might crop
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Text section
            Expanded(
              // Use Expanded for text section as well
              flex: 2, // Adjust flex factor as needed
              child: Padding(
                padding: const EdgeInsets.all(10), // Uniform padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment
                          .end, // Push text to bottom of its allocated space
                  children: [
                    // Price + title on one line
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandButton(String brand) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8), // Horizontal spacing
      constraints: BoxConstraints(
        minWidth: 120, // Minimum width for all items
        maxWidth: 120, // Maximum width for all items
      ),
      child: GlassContainer(
        blur: 20,
        borderRadius: BorderRadius.circular(24),
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Center(
            child: Text(
              brand,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final List<String> _routes = const [
    '/homepage',
    '/search',
    '/add_product',
    '/messages',
    '/profile',
  ];

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        debugPrint('→ Navigating to ${_routes[index]}');
        Navigator.pushNamed(context, _routes[index]);
      },
      items: [
        _buildNavItem(Icons.home, 0),
        _buildNavItem(Icons.search, 1),
        _buildNavItem(Icons.add, 2),
        _buildNavItem(Icons.message, 3),
        _buildNavItem(Icons.person, 4),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration:
            _currentIndex == index
                ? BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                )
                : null,
        padding: EdgeInsets.all(8),
        child: Icon(icon),
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // For the gradient to show through
      extendBody: true, // Extends body behind bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Container(
        // Apply gradient to the main container
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E2F89), Color(0xFF30C8A5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : ListView(
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildSectionTitle('Articles Populaires'),
                    if (_filteredProducts.isNotEmpty)
                      CarouselSlider(
                        items:
                            _filteredProducts.map((product) {
                              return _buildProductCard(
                                context,
                                product,
                              );
                            }).toList(),
                        options: CarouselOptions(
                          height: 250,
                          autoPlay: true,
                          // Set interval equal to animation duration for continuous scroll
                          autoPlayInterval: Duration(
                            milliseconds: 2000,
                          ), // How long each item stays visible
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 500,
                          ), // Speed of transition
                          autoPlayCurve:
                              Curves
                                  .linear, // Constant speed for "flowless" effect
                          enlargeCenterPage:
                              false, // Set to false for items to be closer and uniform
                          viewportFraction:
                              0.5, // Shows roughly 3 items (1.0 / 0.35 = ~2.85)
                          // Adjust to 0.3 for ~3.3 items, 0.25 for 4 items
                          // reverse: true, // Kept as per original code, remove if not desired
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 50.0,
                        ),
                        child: Center(
                          child: Text(
                            'Aucun article trouvé.',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    _buildSectionTitle('Achetez par marque'),
                    if (_brands.isNotEmpty)
                      CarouselSlider(
                        items:
                            _brands
                                .map((brand) => _buildBrandButton(brand))
                                .toList(),
                        options: CarouselOptions(
                          height: 40,
                          autoPlay: true,
                          autoPlayInterval: Duration(milliseconds: 1500),
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 500,
                          ),
                          autoPlayCurve: Curves.linear,
                          viewportFraction: 0.24,
                          // Add these parameters for consistent spacing:
                          enableInfiniteScroll: true,
                          padEnds: false,
                          disableCenter: true,
                          pageSnapping: false,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20.0,
                        ),
                        child: Center(
                          child: Text(
                            'Aucune marque disponible.',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 80,
                    ), // Add some padding at the bottom if extendBody is true
                  ],
                ),
      ),
    );
  }
}
