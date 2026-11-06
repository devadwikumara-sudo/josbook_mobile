import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/biodata/biodata_screen.dart';
import 'features/home/home_screen.dart';
import 'features/nilai/nilai_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/unduh/unduh_screen.dart';

class JosBookApp extends StatefulWidget {
  const JosBookApp({super.key});

  @override
  State<JosBookApp> createState() => _JosBookAppState();
}

class _JosBookAppState extends State<JosBookApp> {
  late final GoRouter _router;

  /// Menjadi true setelah animasi splash selesai.
  final ValueNotifier<bool> _splashSelesai = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/mulai',
      refreshListenable: Listenable.merge([auth, _splashSelesai]),
      redirect: (context, state) {
        final lokasi = state.matchedLocation;

        // Tahan di splash sampai animasi selesai DAN pengecekan auth selesai.
        final bool masihSplash =
            !_splashSelesai.value || auth.status == AuthStatus.memeriksa;
        if (masihSplash) {
          return lokasi == '/mulai' ? null : '/mulai';
        }

        switch (auth.status) {
          case AuthStatus.memeriksa:
            return lokasi == '/mulai' ? null : '/mulai';
          case AuthStatus.belumLogin:
            // Login dan Daftar sama-sama boleh diakses saat belum login.
            return (lokasi == '/login' || lokasi == '/daftar')
                ? null
                : '/login';
          case AuthStatus.sudahLogin:
            return (lokasi == '/mulai' ||
                    lokasi == '/login' ||
                    lokasi == '/daftar')
                ? '/home'
                : null;
        }
      },
      routes: [
        GoRoute(
          path: '/mulai',
          builder: (_, __) => SplashScreen(
            onSelesai: () => _splashSelesai.value = true,
          ),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/daftar', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/biodata', builder: (_, __) => const BiodataScreen()),
        GoRoute(path: '/nilai', builder: (_, __) => const NilaiScreen()),
        GoRoute(path: '/unduh', builder: (_, __) => const UnduhScreen()),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _splashSelesai.dispose();
    super.dispose();
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