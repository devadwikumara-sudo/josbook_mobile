import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../home_warna.dart';

/// Kartu "Login berhasil" yang meluncur dari atas layar.
class ToastLogin extends StatelessWidget {
  const ToastLogin({super.key, required this.tampil});

  final bool tampil;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: tampil ? Offset.zero : const Offset(0, -1.8),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: tampil ? 1 : 0,
        duration: const Duration(milliseconds: 240),
        child: Semantics(
          liveRegion: true,
          child: Material(
            color: Colors.white,
            elevation: 6,
            shadowColor: Colors.black38,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: HomeWarna.hijauMuda,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: HomeWarna.hijau.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: HomeWarna.hijau),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Login berhasil',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: WarnaJosBook.teks,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: HomeWarna.hijau,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Selamat datang kembali di JosBook!',
                          style: TextStyle(
                              fontSize: 13, color: HomeWarna.teksPudar),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}