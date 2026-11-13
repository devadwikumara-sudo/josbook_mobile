import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../auth/auth_warna.dart';

/// Tab "Masuk" | "Daftar" di bagian atas form.
class TabAuth extends StatelessWidget {
  const TabAuth({
    super.key,
    required this.masukAktif,
    required this.onMasuk,
    required this.onDaftar,
  });

  final bool masukAktif;
  final VoidCallback onMasuk;
  final VoidCallback onDaftar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuthWarna.latarTab,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Item(teks: 'Masuk', aktif: masukAktif, onTap: onMasuk),
          _Item(teks: 'Daftar', aktif: !masukAktif, onTap: onDaftar),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.teks, required this.aktif, required this.onTap});

  final String teks;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: aktif,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: aktif ? WarnaJosBook.navy : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              teks,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: aktif ? Colors.white : WarnaJosBook.teks,
              ),
            ),
          ),
        ),
      ),
    );
  }
}