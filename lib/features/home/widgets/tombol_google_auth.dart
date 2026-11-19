import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../auth/auth_warna.dart';

/// Tombol "Masuk dengan Google". Backend belum mendukung, jadi tampil sesuai
/// desain tetapi berstatus "segera hadir" (hanya menampilkan info saat disentuh).
class TombolGoogleAuth extends StatelessWidget {
  const TombolGoogleAuth({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: WarnaJosBook.biru,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Masuk dengan Google',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: WarnaJosBook.teks,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AuthWarna.latarTab,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Segera hadir',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AuthWarna.teksPudar,
                      ),
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