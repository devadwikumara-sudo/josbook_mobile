import 'package:flutter/material.dart';

import '../home_warna.dart';

/// Baris paling atas: logo, nama aplikasi + sekolah, dan lonceng notifikasi.
class HeaderHome extends StatelessWidget {
  const HeaderHome({
    super.key,
    required this.sekolah,
    required this.adaNotifikasiBaru,
    required this.onNotifikasi,
  });

  final String sekolah;
  final bool adaNotifikasiBaru;
  final VoidCallback onNotifikasi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'assets/images/josbook-logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.school_rounded, color: Color(0xFF062A6B)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'JosBook',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Buku Induk siswa $sekolah',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: adaNotifikasiBaru
              ? 'Notifikasi, ada yang belum dibaca'
              : 'Notifikasi',
          child: Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onNotifikasi,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                    if (adaNotifikasiBaru)
                      Positioned(
                        right: 12,
                        top: 11,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: HomeWarna.merahTitik,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}