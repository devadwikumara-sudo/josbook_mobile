import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../home_data.dart';
import '../home_warna.dart';
import 'animasi_home.dart';

List<BoxShadow> _bayangan() => [
      BoxShadow(
        color: WarnaJosBook.navy.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
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
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: WarnaJosBook.biru,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Ringkasan Akademik',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: WarnaJosBook.teks,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            KartuTekan(
              skalaTekan: 0.94,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onSemester,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: HomeWarna.garisKartu),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: WarnaJosBook.biru,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Semester ${data.semester}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: WarnaJosBook.teks,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: HomeWarna.teksPudar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HomeWarna.garisKartu),
            boxShadow: _bayangan(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: WarnaJosBook.biruMuda,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 18,
                      color: WarnaJosBook.biru,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ringkasan semester ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: WarnaJosBook.teks,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Kelas Saat Ini',
                      konten: Text(
                        data.kelas,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: WarnaJosBook.navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: 'Status Siswa',
                      konten: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: aktif
                                ? HomeWarna.hijauMuda
                                : HomeWarna.chipAbu,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: aktif
                                      ? HomeWarna.hijau
                                      : HomeWarna.teksPudar,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                data.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: aktif
                                      ? HomeWarna.hijau
                                      : HomeWarna.teksPudar,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Pintasan(
          ikon: Icons.menu_book_rounded,
          warnaIkon: WarnaJosBook.navy,
          latarIkon: WarnaJosBook.biruMuda,
          label: 'Buku Induk',
          sublabel: 'Lihat biodata lengkap siswa',
          onTap: onBukuInduk,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Pintasan(
                ikon: Icons.bar_chart_rounded,
                warnaIkon: WarnaJosBook.biru,
                latarIkon: WarnaJosBook.biruMuda,
                label: 'Nilai per semester',
                onTap: onNilai,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Pintasan(
                ikon: Icons.download_rounded,
                warnaIkon: HomeWarna.hijau,
                latarIkon: HomeWarna.hijauMuda,
                label: 'Unduh dokumen',
                onTap: onUnduh,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.konten});

  final String label;
  final Widget konten;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: HomeWarna.latar,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarna.garisKartu),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: HomeWarna.teksPudar,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          konten,
        ],
      ),
    );
  }
}

class _Pintasan extends StatelessWidget {
  const _Pintasan({
    required this.ikon,
    required this.warnaIkon,
    required this.latarIkon,
    required this.label,
    required this.onTap,
    this.sublabel,
  });

  final IconData ikon;
  final Color warnaIkon;
  final Color latarIkon;
  final String label;
  final String? sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: KartuTekan(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HomeWarna.garisKartu),
            boxShadow: _bayangan(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: latarIkon,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(ikon, size: 19, color: warnaIkon),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              height: 1.2,
                              color: WarnaJosBook.teks,
                            ),
                          ),
                          if (sublabel != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              sublabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: HomeWarna.teksPudar,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: HomeWarna.teksPudar,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
