import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'discovery_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait 2 seconds, then navigate to the next screen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DiscoveryScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E2F89), Color(0xFF30C8A5)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/logo.svg', width: 280),
              const SizedBox(height: 30),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Re',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'Tech',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
