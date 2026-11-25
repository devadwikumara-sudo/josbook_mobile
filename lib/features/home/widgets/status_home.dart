import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../shared/widgets/state_views.dart';
import '../home_warna.dart';

/// Tampilan sementara saat data Home sedang dimuat dengan efek shimmer halus.
class SkeletonHome extends StatefulWidget {
  const SkeletonHome({super.key});

  @override
  State<SkeletonHome> createState() => _SkeletonHomeState();
}

class _SkeletonHomeState extends State<SkeletonHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _denyut;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _denyut = Tween<double>(begin: 0.35, end: 0.72).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _blok(double tinggi, {double? lebar, double radius = 14, bool terang = true}) {
    final Color dasar = terang ? Colors.white : WarnaJosBook.biruMuda;
    return AnimatedBuilder(
      animation: _denyut,
      builder: (context, _) => Container(
        width: lebar,
        height: tinggi,
        decoration: BoxDecoration(
          color: dasar.withValues(alpha: _denyut.value),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _blok(46, lebar: 46, radius: 14),
            const SizedBox(width: 12),
            Expanded(child: _blok(38)),
            const SizedBox(width: 12),
            _blok(46, lebar: 46, radius: 23),
          ]),
          const SizedBox(height: 22),
          _blok(116, radius: 22),
          const SizedBox(height: 24),
          _blok(22, lebar: 180, terang: false),
          const SizedBox(height: 12),
          _blok(130, radius: 20, terang: false),
          const SizedBox(height: 14),
          _blok(66, radius: 18, terang: false),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _blok(66, radius: 18, terang: false)),
            const SizedBox(width: 12),
            Expanded(child: _blok(66, radius: 18, terang: false)),
          ]),
        ],
      ),
    );
  }
}

/// Tampilan saat data Home gagal dimuat.
class ErrorHome extends StatelessWidget {
  const ErrorHome({super.key, required this.pesan, required this.onUlang});

  final String pesan;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
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
        child: ErrorStateView(
          icon: Icons.cloud_off_rounded,
          iconColor: HomeWarna.teksPudar,
          title: 'Data belum bisa dimuat',
          message: pesan,
          onRetry: onUlang,
          filledButton: true,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: WarnaJosBook.teks,
          ),
          messageStyle: const TextStyle(color: HomeWarna.teksPudar),
        ),
      ),
    );
  }
}
