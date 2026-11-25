import 'package:flutter/material.dart';

import '../home_warna.dart';
import 'animasi_home.dart';

/// Baris paling atas: logo, nama aplikasi + sekolah, dan lonceng notifikasi.
class HeaderHome extends StatelessWidget {
  const HeaderHome({
    super.key,
    required this.sekolah,
    required this.jumlahBelumDibaca,
    required this.onNotifikasi,
  });

  final String sekolah;
  final int jumlahBelumDibaca;
  final VoidCallback onNotifikasi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Buku Induk siswa $sekolah',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: jumlahBelumDibaca > 0
              ? 'Notifikasi, $jumlahBelumDibaca belum dibaca'
              : 'Notifikasi',
          child: KartuTekan(
            skalaTekan: 0.92,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              child: Material(
                color: Colors.transparent,
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
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                        Positioned(
                          right: 6,
                          top: 5,
                          child: AnimatedScale(
                            scale: jumlahBelumDibaca > 0 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutBack,
                            child: jumlahBelumDibaca > 9
                                ? Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: HomeWarna.merahTitik,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      jumlahBelumDibaca > 99
                                          ? '99+'
                                          : '$jumlahBelumDibaca',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: HomeWarna.merahTitik,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
