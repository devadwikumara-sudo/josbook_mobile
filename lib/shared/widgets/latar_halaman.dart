import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'animasi_josbook.dart';

/// Warna latar lembut yang konsisten dengan dashboard.
const Color latarHalamanJosBook = Color(0xFFF6F8FC);
const Color garisKartuJosBook = Color(0xFFE3EAF5);
const Color teksPudarJosBook = Color(0xFF6B7690);

/// Latar belakang gradasi biru-ke-putih yang smooth dengan aksen lingkaran lembut.
class LatarGradasiJosBook extends StatelessWidget {
  const LatarGradasiJosBook({
    super.key,
    required this.child,
    this.stops = const [0.0, 0.20, 0.38, 0.56],
  });

  final Widget child;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      WarnaJosBook.navy,
                      WarnaJosBook.biru,
                      Color(0xFFBFD7FB),
                      latarHalamanJosBook,
                    ],
                    stops: stops,
                  ),
                ),
              ),
              Positioned(
                top: -55,
                right: -40,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: -50,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// Header halaman modern dengan tombol kembali glassmorphism dan judul tengah.
class HeaderHalamanJosBook extends StatelessWidget {
  const HeaderHalamanJosBook({
    super.key,
    required this.judul,
    required this.onKembali,
    this.tooltipKembali = 'Kembali',
  });

  final String judul;
  final VoidCallback onKembali;
  final String tooltipKembali;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Row(
        children: [
          const SizedBox(width: 16),
          KartuTekan(
            skalaTekan: 0.92,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              child: IconButton(
                tooltip: tooltipKembali,
                onPressed: onKembali,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }
}
