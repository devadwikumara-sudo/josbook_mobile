import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../home_data.dart';
import '../home_warna.dart';

/// Bagian "Aktivitas Terbaru" (maksimal 3 baris) + tautan "Lihat Semua".
class AktivitasHome extends StatelessWidget {
  const AktivitasHome({
    super.key,
    required this.items,
    required this.onItem,
    required this.onLihatSemua,
    this.memuat = false,
    this.pesanError,
    this.onUlang,
  });

  final List<ItemAktivitas> items;
  final VoidCallback onItem;
  final VoidCallback onLihatSemua;
  final bool memuat;
  final String? pesanError;
  final VoidCallback? onUlang;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: WarnaJosBook.biru,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: WarnaJosBook.teks,
                ),
              ),
            ),
            TextButton(
              onPressed: onLihatSemua,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: WarnaJosBook.biru,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: memuat
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : pesanError != null && items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        'Aktivitas gagal dimuat.\n$pesanError',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: HomeWarna.teksPudar),
                      ),
                      if (onUlang != null)
                        TextButton(
                          onPressed: onUlang,
                          child: const Text('Coba lagi'),
                        ),
                    ],
                  ),
                )
              : items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada aktivitas.',
                      style: TextStyle(color: HomeWarna.teksPudar),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final ItemAktivitas item in items.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _Baris(item: item, onTap: onItem),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris({required this.item, required this.onTap});

  final ItemAktivitas item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color warna = item.peringatan ? HomeWarna.oranye : HomeWarna.hijau;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HomeWarna.garisKartu),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: warna,
                child: Icon(
                  item.peringatan
                      ? Icons.schedule_rounded
                      : Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: WarnaJosBook.navy,
                      ),
                    ),
                    if (item.waktu.isNotEmpty)
                      Text(
                        item.waktu,
                        style: const TextStyle(
                          fontSize: 11,
                          color: HomeWarna.teksPudar,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: HomeWarna.teksPudar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
