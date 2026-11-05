import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../auth_warna.dart';

/// Latar gradasi biru + area aman + isi yang bisa di-scroll.
/// Dipakai bersama oleh semua layar autentikasi.
class LatarAuth extends StatelessWidget {
  const LatarAuth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AuthWarna.gradasiTengah, WarnaJosBook.navy],
          stops: [0.25, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}