import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

  final List<String> _carouselTexts = [
    'Welcome to FitLife!',
    'Track your progress easily.',
    'Join the fitness revolution.',
  ];

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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_intro', true);

      context.go(
        '/dashboard',
        extra: {
          'name': userCredential.user?.displayName ?? '',
          'email': userCredential.user?.email ?? '',
          'photoUrl': userCredential.user?.photoURL ?? '',
        },
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-In Failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _skipLogin() {
    context.go(
      '/dashboard',
      extra: {'name': 'Guest User', 'email': '', 'photoUrl': ''},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // const FlutterLogo(size: 80),
              Image.network(
                'https://cdn.dribbble.com/userupload/42892161/file/original-8af6a870ca94d4f00bb67d16562c7ee1.jpg?resize=1024x768&vertical=center', // 🔁 Replace with your actual logo URL
                height: 80,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 40);
                },
              ),

              const SizedBox(height: 20),

              /// 🚀 Carousel using flutter_carousel_widget
              FlutterCarousel(
                options: CarouselOptions(
                  height: 350,
                  autoPlay: true,
                  enableInfiniteScroll: true,
                  slideIndicator: CircularSlideIndicator(),
                  enlargeCenterPage: true,
                  viewportFraction: 0.7,
                  pageSnapping: true,
                  aspectRatio: 2.0,
                  initialPage: 2,
                ),
                items:
                    [
                      'https://images.pexels.com/photos/791763/pexels-photo-791763.jpeg',
                      'https://images.pexels.com/photos/7673595/pexels-photo-7673595.jpeg',
                      'https://images.pexels.com/photos/3757954/pexels-photo-3757954.jpeg',
                    ].map((imageUrl) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
              ),
              const Spacer(),

              /// 🔽 Buttons at the bottom
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(
                          Icons.login,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ), // Google Blue
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ), // Google Blue
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          shadowColor: Colors.black12,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _skipLogin,
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
