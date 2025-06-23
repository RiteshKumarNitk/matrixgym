import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrixgym/modules/splash/splash_page.dart';
import 'package:matrixgym/modules/intro/intro_page.dart';
import 'package:matrixgym/modules/auth/login_page.dart';
import 'package:matrixgym/modules/dashboard/views/dashboard_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/intro', builder: (context, state) => const IntroPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
    
  ],
);
