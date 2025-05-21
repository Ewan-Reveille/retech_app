import 'package:flutter/material.dart';
import './widgets/three_carousels.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  // Replace these with your actual client IDs from Google Cloud Console
  static const String _webClientId  = '564913474567-8ru48jsns9cpnqpkdo7coqlppo6opod7.apps.googleusercontent.com ';
  static const String _androidClientId = '564913474567-qouq43cifimbc6jvlj7407967d2p0tbv.apps.googleusercontent.com';

  Future<void> _signInWithGoogle() async {
    final supabase = Supabase.instance.client;

    // Configure GoogleSignIn with platform-specific client IDs
    final googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['openid', 'email', 'profile'],
    );

    // Start the sign-in flow
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // User cancelled the sign-in
      return;
    }
    final googleAuth = await googleUser.authentication;

    final idToken     = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || accessToken == null) {
      throw Exception('Missing Google ID Token or Access Token.');
    }

    // Sign in (or up) with Supabase using Google ID & Access tokens
    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E2F89), Color(0xFF30C8A5)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  ThreeCarousels(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const Text(
                          'Achetez, ou vendez vos objets technologiques !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.white54, blurRadius: 5)],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Créer un compte
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushNamed('/auth/signup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Créer un compte', style: TextStyle(color: Colors.black, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // J'ai déjà un compte
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pushNamed('/auth/login'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("J'ai déjà un compte", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Continuer avec l'un de vos comptes",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google & Apple buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SignInButton(
                              Buttons.Google,
                              text: 'Google',
                              onPressed: _signInWithGoogle,
                            ),
                            const SizedBox(width: 16),
                            SignInButton(
                              Buttons.Apple,
                              onPressed: () async {
                                final supabase = Supabase.instance.client;
                                await supabase.auth.signInWithOAuth(
                                  OAuthProvider.apple,
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
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
}
