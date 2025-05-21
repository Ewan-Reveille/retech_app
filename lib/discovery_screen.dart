import 'package:flutter/material.dart';
import 'onboarding/page_one.dart';
import 'onboarding/page_two.dart';
import 'onboarding/page_three.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // Suivi de la page active.
  int currentIndex = 0;
  final List<Widget> pages = [
    PageOne(key: ValueKey("pageOne")),
    PageTwo(key: ValueKey("pageTwo")),
    PageThree(key: ValueKey("pageThree")),
  ];

  // Gestion du swipe horizontal
  void onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < 0 && currentIndex < pages.length - 1) {
      setState(() => currentIndex++);
    } else if (details.primaryVelocity! > 0 && currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  // Navigation vers la page de connexion
  void goToLogin() {
    debugPrint('→ Navigating to /login');
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Indicateur de page personnalisé
  Widget buildIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pages.length, (index) {
        bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 50 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF30C8A5) : Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le gradient de fond reste présent pendant la transition.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E2F89), Color(0xFF30C8A5)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          children: [
            // Affichage de la page actuelle avec gesture pour le swipe
            GestureDetector(
              onHorizontalDragEnd: onHorizontalDragEnd,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: pages[currentIndex],
              ),
            ),
            // L’indicateur de page en bas de l’écran
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(child: buildIndicator()),
            ),
            // Bouton pour passer à la page de connexion à la dernière page
            if (currentIndex == pages.length - 1)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: goToLogin,
                    child: const Text("Commencer"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
