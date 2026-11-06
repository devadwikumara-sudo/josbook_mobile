import 'package:flutter/material.dart';

import '../home_data.dart';

/// Foto + "Halo, {nama} 👋" + chip kelas dan NISN.
class SapaanHome extends StatelessWidget {
  const SapaanHome({super.key, required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarSiswa(nama: data.nama, fotoUrl: data.fotoUrl),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selamat datang di aplikasi buku induk sekolah',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Kelas ${data.kelas} | NISN: ${data.nisn}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Foto bulat siswa; bila tidak ada / gagal dimuat, tampil inisial nama.
class AvatarSiswa extends StatelessWidget {
  const AvatarSiswa({
    super.key,
    required this.nama,
    required this.fotoUrl,
    this.ukuran = 92,
  });

  final String nama;
  final String? fotoUrl;
  final double ukuran;

  String get _inisial {
    final List<String> kata =
        nama.trim().split(RegExp(r'\s+')).where((k) => k.isNotEmpty).toList();
    if (kata.isEmpty) return '?';
    final String awal = kata.first[0];
    final String akhir = kata.length > 1 ? kata[1][0] : '';
    return (awal + akhir).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Widget inisial = Container(
      color: const Color(0xFFEAF2FF),
      alignment: Alignment.center,
      child: Text(
        _inisial,
        style: TextStyle(
          fontSize: ukuran * 0.34,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF062A6B),
        ),
      ),
    );

    return Semantics(
      label: 'Foto $nama',
      child: Container(
        width: ukuran,
        height: ukuran,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: (fotoUrl == null)
              ? inisial
              : Image.network(
                  fotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => inisial,
                ),
        ),
      ),
    );
  }
}