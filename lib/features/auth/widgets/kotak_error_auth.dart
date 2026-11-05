import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../auth_warna.dart';

/// Kotak error merah muda di atas form (desain: "Login gagal").
class KotakErrorAuth extends StatelessWidget {
  const KotakErrorAuth({super.key, required this.judul, required this.pesan});

  final String judul;
  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AuthWarna.latarError,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WarnaJosBook.merah.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: WarnaJosBook.merah),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: WarnaJosBook.merah,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pesan,
                  style: const TextStyle(
                    fontSize: 13,
                    color: WarnaJosBook.teks,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}