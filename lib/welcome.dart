import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  final List<String> _routes = const [
    '/homepage',
    '/search',
    '/add_product',
    '/messages',
    '/profile',
  ];
  // Dummy data for popular items
  final List<_Item> popularItems = const [
    _Item('Iphone 13', '200 €', 'Apple', '64 GB', 'assets/iphone13.jpg'),
    _Item('Iphone 15', '650 €', 'Apple', '256 GB', 'assets/iphone15.jpg'),
    _Item('Galaxy S21', '400 €', 'Samsung', '128 GB', 'assets/galaxy_s21.jpg'),
  ];

  // Brand list
  final List<String> brands = const [
    'Logitech',
    'LG',
    'Samsung',
    'Apple',
    'Xiaomi',
    'Razer',
    'Sony',
    'Nokia',
    'Asus',
    'Huawei',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // since this is the “search” tab
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onTap: (index) {
          print(index);
          if (index == 1) return; // already on search
          Navigator.pushReplacementNamed(context, _routes[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),

      // Body with gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5E4BD8), Color(0xFF19C3A3)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title + icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Accueil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: const [
                      _CircleButton(icon: Icons.favorite_border),
                      SizedBox(width: 12),
                      _CircleButton(icon: Icons.notifications_none),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Color(0xFF19C3A3)),
                    hintText: 'Rechercher des objets ou des membres',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Popular articles title
              const Text(
                'Articles populaires',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Horizontal list of cards
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final item = popularItems[i];
                    return _PopularCard(item: item);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Brands title
              const Text(
                'Achetez par marque',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Wrap of brand chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    brands
                        .map(
                          (b) => Chip(
                            label: Text(b),
                            backgroundColor: Colors.white24,
                            labelStyle: const TextStyle(color: Colors.white),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model for an item
class _Item {
  final String title, price, brand, capacity, assetPath;
  const _Item(
    this.title,
    this.price,
    this.brand,
    this.capacity,
    this.assetPath,
  );
}

// Card widget for popular item
class _PopularCard extends StatelessWidget {
  final _Item item;
  const _PopularCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Price & title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.price,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Brand & capacity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.brand, style: const TextStyle(color: Colors.grey)),
              Text(item.capacity, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// Small circular icon button
class _CircleButton extends StatelessWidget {
  final IconData icon;
  const _CircleButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: Colors.white),
    );
  }
}
