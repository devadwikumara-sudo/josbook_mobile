import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

/// "Sesi Masih Aktif": muncul saat aplikasi dibuka dan token lama masih berlaku.
class SesiAktifScreen extends StatelessWidget {
  const SesiAktifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nama = (auth.namaPengguna ?? '').trim();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEBFF), Colors.white, Color(0xFFEFF6FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 70),
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1DB87A),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D1DB87A),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Sesi Masih Aktif',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2347),
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: Color(0xFF7A869E),
                    ),
                    children: [
                      const TextSpan(
                        text: 'Anda sudah login sebelumnya.\n'
                            'Apakah ingin melanjutkan sebagai\n',
                      ),
                      TextSpan(
                        text: nama.isEmpty ? 'akun ini' : nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF51607F),
                        ),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      context.read<AuthProvider>().lanjutkanSesi();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5BD8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => context.go('/logout-semua?dari=sesi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF123A82),
                      side: const BorderSide(color: Color(0xFFD6E0F0)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
