import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets/state_views.dart';
import '../home/home_data.dart';
import 'notifikasi_model.dart';
import 'notifikasi_provider.dart';
import 'notifikasi_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key, this.service});

  final NotifikasiService? service;

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  late final NotifikasiProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NotifikasiProvider(
      service: widget.service ?? HttpNotifikasiService(),
    );
    unawaited(_muatDanTandaiBaca());
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _muatDanTandaiBaca() async {
    await _provider.muat();
    if (!mounted || _provider.error != null) return;
    try {
      await _provider.tandaiSemuaDibaca();
    } catch (error) {
      if (!mounted) return;
      _pesanError('Notifikasi gagal ditandai sebagai dibaca: $error');
    }
  }

  Future<void> _tandaiBaca(Notifikasi item) async {
    try {
      await _provider.tandaiDibaca(item.id);
    } catch (error) {
      if (!mounted) return;
      _pesanError('Notifikasi gagal ditandai sebagai dibaca: $error');
    }
  }

  void _pesanError(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WarnaJosBook.navy,
              WarnaJosBook.biru,
              Color(0xFFEAF2FF),
              Colors.white,
            ],
            stops: [0, 0.18, 0.36, 0.54],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Notifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _provider,
                  builder: (context, _) => _isi(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _isi() {
    if (_provider.memuat && _provider.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat notifikasi...'),
          ],
        ),
      );
    }

    if (_provider.error != null && _provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ErrorStateView(
            title: 'Notifikasi gagal dimuat.',
            message: _provider.error!,
            onRetry: () => unawaited(_muatDanTandaiBaca()),
            icon: Icons.cloud_off_outlined,
            iconSize: 42,
            titleStyle: const TextStyle(color: WarnaJosBook.teks),
            messageStyle: const TextStyle(color: WarnaJosBook.teks),
            retryIcon: Icons.refresh_rounded,
          ),
        ),
      );
    }

    if (_provider.items.isEmpty) {
      return const Center(
        child: EmptyStateView(
          title: 'Belum ada notifikasi',
          message: 'Notifikasi terbaru akan muncul di sini.',
          icon: Icons.notifications_none_rounded,
          iconSize: 48,
          titleStyle: TextStyle(
            color: WarnaJosBook.teks,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          padding: EdgeInsets.all(28),
          textStyle: TextStyle(color: Color(0xFF718096)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _muatDanTandaiBaca,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        itemCount: _provider.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _provider.items[index];
          return _KartuNotifikasi(
            item: item,
            onTap: () => unawaited(_tandaiBaca(item)),
          );
        },
      ),
    );
  }
}

class _KartuNotifikasi extends StatelessWidget {
  const _KartuNotifikasi({required this.item, required this.onTap});

  final Notifikasi item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color warna = switch (item.jenis.toLowerCase()) {
      'peringatan' || 'warning' => const Color(0xFFED9B24),
      'berhasil' || 'success' => const Color(0xFF25A56A),
      'nilai' || 'akademik' => const Color(0xFF397DE0),
      _ => const Color(0xFF8264C8),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE5F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12062A6B),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: warna.withValues(alpha: 0.12),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: warna,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judul,
                      style: const TextStyle(
                        color: WarnaJosBook.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.deskripsi,
                      style: const TextStyle(
                        color: WarnaJosBook.teks,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      formatWaktuWib(item.waktu),
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.dibaca) ...[
                const SizedBox(width: 8),
                Semantics(
                  label: 'Belum dibaca',
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFF2F80ED),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
