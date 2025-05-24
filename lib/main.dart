import 'package:flutter/material.dart';
import 'package:retech_app/auth/signup_page.dart';
import './splash_screen.dart';
import './login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:retech_app/auth/login_page.dart';
import './home_page.dart';
import './search_page.dart';
import './products_page.dart';
import 'product_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import './add_product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dwaqvnfufbnrxzypowbz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3YXF2bmZ1ZmJucnh6eXBvd2J6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1NDM3MjEsImV4cCI6MjA1ODExOTcyMX0.CaFI95T5q2wwiWapxSfbXlX4PMAEvqU29ttXDalHvDE',
  );

  Stripe.publishableKey = 'pk_test_51R55AaDORmFWPQ5Qlfc3YwcQJicPMOA96nwcmRDhr10nFcj2UcaG00TRGGtq5VXG2HApMpcIlyjSFUdFVUrA8zCj00SG49nt5O';



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReTech',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/auth/login': (context) => const LoginPage(),
        '/auth/signup': (context) => const SignUpPage(),
        '/homepage': (context) => HomePage(),
        '/search': (ctx) => const SearchPage(),
        '/products': (ctx) {
          final category = ModalRoute.of(ctx)!.settings.arguments as String;
          return ProductsPage(categorySlug: category);
        },
        '/product/:id': (ctx) {
          final raw = ModalRoute.of(ctx)!.settings.arguments;
          debugPrint(
            '📦 /product/:id got arguments: $raw (${raw.runtimeType})',
          );
          String stringId;
          try {
            if (raw is String)
              stringId = raw;
            else if (raw is int)
              stringId = raw.toString();
            else
              throw FormatException('Unrecognized type');
          } catch (e, st) {
            debugPrint('‼️ Failed to coerce productId: $e\n$st');
            rethrow;
          }
          return ProductPage(productId: stringId);
        },
        '/add_product': (ctx) => AddProductPage(),
      },
    );
  }
}

// export PATH=$JAVA_HOME/bin:$PATH
// export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
