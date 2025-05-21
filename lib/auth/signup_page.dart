import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _identifierController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final identifier = _identifierController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'identifier': identifier},
      );

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildStyledInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: Colors.white70, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
    );
  }

  Future<void> _createAccount() async {
    final url = Uri.parse('http://185.98.136.156:8080/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _identifierController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pushReplacementNamed('/homepage');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur lors de la création du compte, veuillez réessayer.")));
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF564E9C),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 🔥 Top Image with Fade to Transparent
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/login/background.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF564E9C)],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 Main Content
            SafeArea(
              bottom: false,
              child: SizedBox(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 180),

                      const Text(
                        "Achetez, en toute sécurité",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // --- All Styled Inputs ---
                      TextField(
                        controller: _identifierController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildStyledInput("Identifiant"),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildStyledInput("E-mail"),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildStyledInput("Mot de passe"),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Créer mon compte',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider with "ou"
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(color: Colors.white70, thickness: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "ou",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.white70, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SignInButton(
                        Buttons.Google,
                        text: 'Continuer avec Google',
                        onPressed: () async {
                          final supabase = Supabase.instance.client;
                          await supabase.auth.signInWithOAuth(
                            OAuthProvider.google,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SignInButton(
                        Buttons.Facebook,
                        text: 'Continuer avec Facebook',
                        onPressed: () async {
                          final supabase = Supabase.instance.client;
                          await supabase.auth.signInWithOAuth(
                            OAuthProvider.facebook,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SignInButton(
                        Buttons.Apple,
                        text: 'Continuer avec Apple',
                        onPressed: () async {
                          final supabase = Supabase.instance.client;
                          await supabase.auth.signInWithOAuth(
                            OAuthProvider.apple,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
