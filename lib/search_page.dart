import 'dart:ui';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // State for bottom nav
  int _currentIndex = 1;
  final List<String> _routes = const [
    '/homepage',
    '/search',
    '/add_product',
    '/messages',
    '/profile',
  ];

  final List<_ItemData> items = const [
    _ItemData(icon: Icons.smartphone, label: 'Smartphone'),
    _ItemData(icon: Icons.laptop,     label: 'Ordinateur'),
    _ItemData(icon: Icons.tablet,     label: 'Tablette'),
    _ItemData(icon: Icons.headset,    label: 'Écouteur'),
    _ItemData(icon: Icons.keyboard,   label: 'Clavier'),
    _ItemData(icon: Icons.mouse,      label: 'Souris'),
    _ItemData(icon: Icons.speaker,    label: 'Enceinte'),
    _ItemData(icon: Icons.bolt,       label: 'Chargeur'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── bottom nav bar ────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          Navigator.pushReplacementNamed(context, _routes[index]);
        },
        items: List.generate(5, (i) {
          IconData icon;
          switch (i) {
            case 0: icon = Icons.home; break;
            case 1: icon = Icons.search; break;
            case 2: icon = Icons.add_circle; break;
            case 3: icon = Icons.mail_outline; break;
            default: icon = Icons.person_outline;
          }
          return BottomNavigationBarItem(
            icon: Container(
              decoration: _currentIndex == i
                  ? BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    )
                  : null,
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: Colors.white),
            ),
            label: '',
          );
        }),
      ),

      // ─── body ─────────────────────────────────────────────────────────
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
              // header + search bar …
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recherche',
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

              // glass grid …
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/products',
                          arguments: item.label,  // <-- passes “Smartphone”, “Ordinateur”, etc.
                        );
                      },
                      child: _GlassCard(icon: item.icon, label: item.label),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _ItemData {
  final IconData icon;
  final String label;
  const _ItemData({required this.icon, required this.label});
}
