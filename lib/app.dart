import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/biodata/biodata_screen.dart';
import 'features/home/home_screen.dart';
import 'features/nilai/nilai_screen.dart';
import 'features/unduh/unduh_screen.dart';

class JosBookApp extends StatefulWidget {
  const JosBookApp({super.key});

  @override
  State<JosBookApp> createState() => _JosBookAppState();
}

class _JosBookAppState extends State<JosBookApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/mulai',
      refreshListenable: auth,
      redirect: (context, state) {
        final lokasi = state.matchedLocation;

        switch (auth.status) {
          case AuthStatus.memeriksa:
            return lokasi == '/mulai' ? null : '/mulai';
          case AuthStatus.belumLogin:
            return lokasi == '/login' ? null : '/login';
          case AuthStatus.sudahLogin:
            return (lokasi == '/mulai' || lokasi == '/login') ? '/home' : null;
        }
      },
      routes: [
        GoRoute(
          path: '/mulai',
          builder: (_, __) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/biodata', builder: (_, __) => const BiodataScreen()),
        GoRoute(path: '/nilai', builder: (_, __) => const NilaiScreen()),
        GoRoute(path: '/unduh', builder: (_, __) => const UnduhScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JosBook',
      debugShowCheckedModeBanner: false,
      theme: temaJosBook(),
      routerConfig: _router,
    );
  }
}
