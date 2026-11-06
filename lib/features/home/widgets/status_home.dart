import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../home_warna.dart';

/// Tampilan sementara saat data Home sedang dimuat.
class SkeletonHome extends StatelessWidget {
  const SkeletonHome({super.key});

  Widget _blok(double tinggi, {double? lebar, double radius = 14}) {
    return Container(
      width: lebar,
      height: tinggi,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _blok(46, lebar: 46, radius: 12),
            const SizedBox(width: 12),
            Expanded(child: _blok(36)),
            const SizedBox(width: 12),
            _blok(46, lebar: 46, radius: 23),
          ]),
          const SizedBox(height: 28),
          Row(children: [
            _blok(92, lebar: 92, radius: 46),
            const SizedBox(width: 16),
            Expanded(child: _blok(80)),
          ]),
          const SizedBox(height: 40),
          _blok(24, lebar: 200),
          const SizedBox(height: 12),
          _blok(120, radius: 18),
          const SizedBox(height: 12),
          _blok(54, radius: 16),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _blok(54, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: _blok(54, radius: 16)),
          ]),
        ],
      ),
    );
  }
}

/// Tampilan saat data Home gagal dimuat.
class ErrorHome extends StatelessWidget {
  const ErrorHome({super.key, required this.pesan, required this.onUlang});

  final String pesan;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: HomeWarna.teksPudar),
            const SizedBox(height: 12),
            const Text(
              'Data belum bisa dimuat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: WarnaJosBook.teks,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HomeWarna.teksPudar),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onUlang,
              style:
                  FilledButton.styleFrom(backgroundColor: WarnaJosBook.navy),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}