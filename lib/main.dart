import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/configuration_error_app.dart';
import 'features/auth/auth_provider.dart';
import 'features/profil/profil_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final String? configurationError = AppConfig.configurationError;
  if (configurationError != null) {
    runApp(ConfigurationErrorApp(message: configurationError));
    return;
  }

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