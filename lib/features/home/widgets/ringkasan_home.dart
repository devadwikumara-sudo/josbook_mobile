import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../home_data.dart';
import '../home_warna.dart';

List<BoxShadow> _bayangan() => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ];

/// Judul + chip semester, kartu ringkasan, dan tiga pintasan.
class RingkasanHome extends StatelessWidget {
  const RingkasanHome({
    super.key,
    required this.data,
    required this.onSemester,
    required this.onBukuInduk,
    required this.onNilai,
    required this.onUnduh,
  });

  final HomeData data;
  final VoidCallback onSemester;
  final VoidCallback onBukuInduk;
  final VoidCallback onNilai;
  final VoidCallback onUnduh;

  @override
  Widget build(BuildContext context) {
    final bool aktif = data.status.toLowerCase() == 'aktif';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ringkasan Nilai Semester',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: WarnaJosBook.teks,
                ),
              ),
            ),
            Material(
              color: HomeWarna.chipAbu,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onSemester,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Semester ${data.semester} ›',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WarnaJosBook.teks,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _bayangan(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan semester ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: WarnaJosBook.teks,
                ),
              ),
              const SizedBox(height: 10),
              _baris('Kelas',
                  Text(data.kelas,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: WarnaJosBook.teks))),
              const Divider(height: 1, color: HomeWarna.garisKartu),
              _baris(
                'Status',
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: aktif ? HomeWarna.hijauMuda : HomeWarna.chipAbu,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: aktif ? HomeWarna.hijau : HomeWarna.teksPudar,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Pintasan(
            ikon: Icons.menu_book_rounded,
            label: 'Buku Induk',
            onTap: onBukuInduk),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Pintasan(
                  ikon: Icons.bar_chart_rounded,
                  label: 'Nilai per semester',
                  onTap: onNilai),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Pintasan(
                  ikon: Icons.download_rounded,
                  label: 'Unduh dokumen',
                  onTap: onUnduh),
            ),
          ],
        ),
      ],
    );
  }

  Widget _baris(String label, Widget nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: HomeWarna.teksPudar, fontSize: 14)),
          nilai,
        ],
      ),
    );
  }
}

class _Pintasan extends StatelessWidget {
  const _Pintasan({
    required this.ikon,
    required this.label,
    required this.onTap,
  });

  final IconData ikon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _bayangan(),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Icon(ikon, size: 20, color: WarnaJosBook.navy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: WarnaJosBook.teks,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: HomeWarna.teksPudar),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}