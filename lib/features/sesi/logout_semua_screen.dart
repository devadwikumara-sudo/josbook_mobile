import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

/// "Logout dari semua perangkat?" — dari menu Keluar Sesi (Profil)
/// atau dari tombol Logout di layar Sesi Masih Aktif.
class LogoutSemuaScreen extends StatefulWidget {
  const LogoutSemuaScreen({super.key, this.dari = 'profil'});

  /// 'profil' atau 'sesi' — menentukan tujuan tombol Batal.
  final String dari;

  @override
  State<LogoutSemuaScreen> createState() => _LogoutSemuaScreenState();
}

class _LogoutSemuaScreenState extends State<LogoutSemuaScreen> {
  bool _memproses = false;

  Future<void> _logoutSemua() async {
    setState(() => _memproses = true);
    // Router otomatis ke /login begitu status auth berubah.
    await context.read<AuthProvider>().logoutSemua();
    if (mounted) setState(() => _memproses = false);
  }

  @override
  Widget build(BuildContext context) {
    final batalKe = widget.dari == 'sesi' ? '/sesi-aktif' : '/profil';

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
                const SizedBox(height: 56),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1F7BF2), Color(0xFF0A3E9E)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4D1F6FEB),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Logout dari semua perangkat?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2347),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Anda akan keluar dari semua perangkat yang sedang login.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF7A869E),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _memproses ? null : _logoutSemua,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF04A63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _memproses
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Logout Semua',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _memproses ? null : () => context.go(batalKe),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF123A82),
                      side: const BorderSide(color: Color(0xFFD6E0F0)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Batal',
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
