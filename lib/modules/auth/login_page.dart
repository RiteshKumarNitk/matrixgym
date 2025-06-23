import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _loading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Save intro flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_intro', true);

      // Navigate to dashboard with user data
      context.go('/dashboard', extra: {
        'name': userCredential.user?.displayName ?? '',
        'email': userCredential.user?.email ?? '',
        'photoUrl': userCredential.user?.photoURL ?? '',
      });
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-In Failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _skipLogin() {
    context.go('/dashboard', extra: {
      'name': 'Guest User',
      'email': '',
      'photoUrl': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 40),
            _loading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _skipLogin,
                        child: const Text('Skip for now'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
