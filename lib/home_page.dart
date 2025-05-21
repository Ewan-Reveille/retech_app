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
  final String title;
  final String image;
  final double price;
  final String description;
  final String category;

  Product({
    required this.title,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
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
      Uri.parse('https://fakestoreapi.com/products'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> productJson = json.decode(response.body);
      setState(() {
        _products =
            productJson.map((jsonItem) => Product.fromJson(jsonItem)).toList();
        _filteredProducts = _products;
        _brands = _products.map((product) => product.category).toSet().toList();
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

  Widget _buildProductCard(Product product) {
    // Using the provided _buildProductCard widget
    return Container(
      width: 159, // This width might be overridden by carousel's viewport logic
      // height: 225, // Height is managed by CarouselOptions.height for the overall carousel
      margin: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ), // Adjusted margin slightly
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
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
                  product.image,
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

                  // Optional: Second line for brand/storage
                  // if ((product.brand ?? '').isNotEmpty ||
                  //     (product.storage ?? '').isNotEmpty) ...[
                  //   const SizedBox(height: 2),
                  //   Text(
                  //     [
                  //       if (product.brand?.isNotEmpty == true) product.brand!,
                  //       if (product.storage?.isNotEmpty == true) product.storage!
                  //     ].join(' • '),
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(
                  //       fontSize: 10,
                  //       color: Colors.grey[700],
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandButton(String brand) {
    return GlassContainer(
      blur: 10,
      linearGradient: LinearGradient(colors: [Colors.white, Colors.white]),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(brand, style: TextStyle(color: Colors.white)),
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
                            _filteredProducts
                                .map((product) => _buildProductCard(product))
                                .toList(),
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
                          height: 60,
                          autoPlay: true,
                          // Set interval equal to animation duration for continuous scroll
                          autoPlayInterval: Duration(
                            milliseconds: 1500,
                          ), // How long each item stays visible
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 500,
                          ), // Speed of transition
                          autoPlayCurve: Curves.linear, // Constant speed
                          viewportFraction:
                              0.3, // Shows 4 brand items (1.0 / 0.25 = 4)
                          // Adjust as needed, e.g., 0.2 for 5 items
                          // reverse: true, // Kept as per original code
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
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
