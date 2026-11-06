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
import 'features/profil/bantuan_screen.dart';
import 'features/profil/data_diri_screen.dart';
import 'features/profil/edit_profil_screen.dart';
import 'features/profil/ganti_password_screen.dart';
import 'features/profil/profil_screen.dart';
import 'features/sesi/logout_semua_screen.dart';
import 'features/sesi/sesi_aktif_screen.dart';
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
            return (lokasi == '/mulai' || lokasi == '/login') ? '/home' : null;
        }
      },
      routes: [
        GoRoute(
          path: '/mulai',
          builder: (_, __) => SplashScreen(
            onSelesai: () => _splashSelesai.value = true,
          ),
        ),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/biodata', builder: (_, _) => const BiodataScreen()),
        GoRoute(path: '/nilai', builder: (_, _) => const NilaiScreen()),
        GoRoute(path: '/unduh', builder: (_, _) => const UnduhScreen()),
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