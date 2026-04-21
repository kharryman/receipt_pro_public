import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:receipt_pro/home.dart';
import '../scan_page.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => ScanPage()),
      GoRoute(path: '/home', builder: (_, __) => HomePage()),
    ],
  );
}
