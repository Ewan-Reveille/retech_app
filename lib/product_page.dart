import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class Product {
  final List<String> imageUrls;
  final String title;
  final String category;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;

  Product({
    required this.imageUrls,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 RAW PRODUCT JSON ➞ $json');
    final imagesJson = json['images'] as List<dynamic>?;
    final imageField = json['image'] is String ? json['image'] as String : null;
    final imageUrls =
        imagesJson != null
            ? imagesJson.map((e) => e as String).toList()
            : (imageField != null ? [imageField] : <String>[]);

    final title = json['title']?.toString() ?? 'Titre inconnu';
    final category = json['category']?.toString() ?? 'Sans catégorie';
    final description = json['description']?.toString() ?? '';
    final price =
        (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0;

    final ratingMap = json['rating'] is Map ? json['rating'] as Map : {};
    final rating =
        (ratingMap['rate'] is num)
            ? (ratingMap['rate'] as num).toDouble()
            : 0.0;
    final reviewCount =
        (ratingMap['count'] is num) ? (ratingMap['count'] as num).toInt() : 0;

    return Product(
      imageUrls: imageUrls,
      title: title,
      category: category,
      description: description,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
    );
  }
}

Future<Product> fetchProductById(String id) async {
  final res = await http.get(
    Uri.parse('https://fakestoreapi.com/products/$id'),
  );
  if (res.statusCode != 200) {
    throw Exception('Erreur ${res.statusCode}');
  }
  return Product.fromJson(json.decode(res.body));
}

Future<void> _handleStripePayment(BuildContext context, Product product) async {
  try {
    // 1. Create payment intent through your backend
    final response = await http.post(
      Uri.parse('your-backend-url/create-payment-intent'),
      body: {
        'amount': (product.price * 100).toInt().toString(),
        'currency': 'eur',
      },
    );

    // 2. Parse response
    final clientSecret = json.decode(response.body)['clientSecret'];
    
    // 3. Initialize Stripe payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Your Store',
      ),
    );
    
    // 4. Display payment interface
    await Stripe.instance.presentPaymentSheet();
    
    // 5. Handle success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful!')),
    );
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $e')),
    );
  }
}

class ProductPage extends StatefulWidget {
  final String productId;
  const ProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<Product> _futureProduct;

  // These define how far up/down the sheet can go
  final double _minTopFraction = 0.15;
  final double _maxTopFraction = 0.60;

  double _top = 0;
  double _initialTop = 0;

  @override
  void initState() {
    super.initState();
    _futureProduct = fetchProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    if (_initialTop == 0) {
      _initialTop = h * _maxTopFraction;
      _top = _initialTop;
    }

    return Scaffold(
      body: FutureBuilder<Product>(
        future: _futureProduct,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur : ${snap.error}'));
          }
          final product = snap.data!;

          return Stack(
            children: [
              // your carousel background, back‑button, etc
              SizedBox(
                height: h,
                width: double.infinity,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                  ),
                  items:
                      product.imageUrls.map((url) {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      }).toList(),
                ),
              ),
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // draggable panel
              AnimatedPositioned(
                duration: const Duration(milliseconds: 0),
                left: 0,
                right: 0,
                top: _top,
                bottom: 0,
                child: GestureDetector(
                  // ② single detector around the panel content
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _top = (_top + details.delta.dy).clamp(
                        h * _minTopFraction,
                        h * _maxTopFraction,
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            RatingBarIndicator(
                              rating: product.rating,
                              itemBuilder:
                                  (_, __) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              itemSize: 20,
                            ),
                            const SizedBox(width: 6),
                            Text('${product.reviewCount} avis'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                label: const Text('Faire une offre'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[100],
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Add offer logic
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.payment, size: 20),
                                label: const Text('Acheter maintenant'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Stripe payment logic
                                  _handleStripePayment(context, product);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(product.description),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
