import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/auth/auth_provider.dart';
import 'features/profil/profil_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..mulai()),
        // Data profil dibuang otomatis begitu pengguna keluar (logout / sesi habis).
        ChangeNotifierProxyProvider<AuthProvider, ProfilProvider>(
          create: (_) => ProfilProvider(),
          update: (_, auth, profil) {
            final p = profil ?? ProfilProvider();
            if (auth.status != AuthStatus.sudahLogin) p.kosongkan();
            return p;
          },
        ),
      ],
      child: const JosBookApp(),
    ),
  );
}