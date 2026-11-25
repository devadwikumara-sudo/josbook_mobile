import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../home_data.dart';

/// Foto + "Halo, {nama} 👋" + chip kelas dan NISN.
class SapaanHome extends StatelessWidget {
  const SapaanHome({super.key, required this.data, required this.foto});

  final HomeData data;
  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    const List<Shadow> bayanganTeks = [
      Shadow(
        color: Color(0x40062A6B),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarSiswa(nama: data.nama, foto: foto, ukuran: 84),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${data.nama} 👋',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                    shadows: bayanganTeks,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang di buku induk sekolah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.94),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    shadows: bayanganTeks,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PillInfo(
                      ikon: Icons.class_rounded,
                      teks: 'Kelas ${data.kelas}',
                    ),
                    _PillInfo(
                      ikon: Icons.badge_outlined,
                      teks: 'NISN ${data.nisn}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillInfo extends StatelessWidget {
  const _PillInfo({required this.ikon, required this.teks});

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: WarnaJosBook.navy.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.38),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            teks,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto bulat siswa; bila tidak ada / gagal dimuat, tampil inisial nama.
class AvatarSiswa extends StatelessWidget {
  const AvatarSiswa({
    super.key,
    required this.nama,
    required this.foto,
    this.ukuran = 92,
  });

  final String nama;
  final Uint8List? foto;
  final double ukuran;

  String get _inisial {
    final List<String> kata = nama
        .trim()
        .split(RegExp(r'\s+'))
        .where((k) => k.isNotEmpty)
        .toList();
    if (kata.isEmpty) return '?';
    final String awal = kata.first[0];
    final String akhir = kata.length > 1 ? kata[1][0] : '';
    return (awal + akhir).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Widget inisial = Container(
      color: WarnaJosBook.biruMuda,
      alignment: Alignment.center,
      child: Text(
        _inisial,
        style: TextStyle(
          fontSize: ukuran * 0.34,
          fontWeight: FontWeight.w800,
          color: WarnaJosBook.navy,
        ),
      ),
    );

    return Semantics(
      label: 'Foto $nama',
      child: Container(
        width: ukuran,
        height: ukuran,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFA9CEFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: WarnaJosBook.navy.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: (foto == null)
              ? inisial
              : Image.memory(
                  foto!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => inisial,
                ),
        ),
      ),
    );
  }
}
