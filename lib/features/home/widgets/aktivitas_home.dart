import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../shared/widgets/state_views.dart';
import '../home_data.dart';
import '../home_warna.dart';
import 'animasi_home.dart';

/// Bagian "Aktivitas Terbaru" (maksimal 3 baris) + tautan "Lihat Semua".
class AktivitasHome extends StatelessWidget {
  const AktivitasHome({
    super.key,
    required this.items,
    required this.onItem,
    required this.onLihatSemua,
    required this.onUlang,
    this.memuat = false,
    this.pesanError,
  });

  final List<ItemAktivitas> items;
  final VoidCallback onItem;
  final VoidCallback onLihatSemua;
  final bool memuat;
  final String? pesanError;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    final List<ItemAktivitas> tampil = items.take(3).toList(growable: false);

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
                'Aktivitas Terbaru',
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
              child: TextButton(
                onPressed: onLihatSemua,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: WarnaJosBook.biru,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: WarnaJosBook.biru,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HomeWarna.garisKartu),
            boxShadow: [
              BoxShadow(
                color: WarnaJosBook.navy.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: WarnaJosBook.biru,
                      ),
                    ),
                  ),
                )
              : pesanError != null && tampil.isEmpty
              ? ErrorStateView(
                  message: 'Aktivitas gagal dimuat.\n$pesanError',
                  onRetry: onUlang,
                  compact: true,
                  messageStyle: const TextStyle(color: HomeWarna.teksPudar),
                )
              : tampil.isEmpty
              ? const EmptyStateView(
                  message: 'Belum ada aktivitas.',
                  textStyle: TextStyle(color: HomeWarna.teksPudar),
                )
              : Column(
                  children: [
                    for (int i = 0; i < tampil.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == tampil.length - 1 ? 0 : 10,
                        ),
                        child: _Baris(item: tampil[i], onTap: onItem),
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
    final Color latar =
        item.peringatan ? HomeWarna.oranyeMuda : HomeWarna.hijauMuda;

    return KartuTekan(
      child: Material(
        color: HomeWarna.latar,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HomeWarna.garisKartu),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: latar,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.peringatan
                        ? Icons.schedule_rounded
                        : Icons.check_rounded,
                    size: 19,
                    color: warna,
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: WarnaJosBook.navy,
                        ),
                      ),
                      if (item.waktu.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.waktu,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: HomeWarna.teksPudar,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: HomeWarna.teksPudar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
