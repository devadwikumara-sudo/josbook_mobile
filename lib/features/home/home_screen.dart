import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';
import '../auth/auth_provider.dart';
import 'home_data.dart';
import 'home_service.dart';
import 'home_warna.dart';
import '../notifikasi/notifikasi_model.dart';
import '../notifikasi/notifikasi_provider.dart';
import '../notifikasi/notifikasi_service.dart';
import 'widgets/aktivitas_home.dart';
import 'widgets/header_home.dart';
import 'widgets/ringkasan_home.dart';
import 'widgets/sapaan_home.dart';
import 'widgets/status_home.dart';
import 'widgets/toast_login.dart';

/// Layar Home / Dashboard siswa.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.notifikasiService});

  final NotifikasiService? notifikasiService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _service = HomeService();
  late final NotifikasiProvider _notifikasiProvider;

  HomeData? _data;
  String? _pesanError;
  bool _memuat = true;

  bool _toastTampil = false;
  Timer? _timerToast;

  @override
  void initState() {
    super.initState();
    _notifikasiProvider = NotifikasiProvider(
      service: widget.notifikasiService ?? HttpNotifikasiService(),
    );
    unawaited(_notifikasiProvider.muat());
    _muat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cekToastLogin());
  }

  @override
  void dispose() {
    _timerToast?.cancel();
    _notifikasiProvider.dispose();
    super.dispose();
  }

  /// Toast "Login berhasil" hanya muncul tepat setelah login.
  void _cekToastLogin() {
    if (!mounted) return;
    final AuthProvider auth = context.read<AuthProvider>();
    if (!auth.barusLogin) return;

    auth.tandaiToastLoginSelesai();
    setState(() => _toastTampil = true);
    _timerToast = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toastTampil = false);
    });
  }

  Future<void> _muat() async {
    try {
      final HomeData data = await _service.muat();
      if (!mounted) return;
      setState(() {
        _data = data;
        _pesanError = null;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      final String pesan = e is ApiException
          ? e.pesan
          : 'Terjadi kesalahan saat memuat data. Coba lagi.';

      if (_data != null) {
        // Data lama tetap tampil; cukup beri tahu bahwa penyegaran gagal.
        _info(pesan);
      } else {
        setState(() {
          _pesanError = pesan;
          _memuat = false;
        });
      }
    }
  }

  void _ulang() {
    setState(() => _memuat = true);
    _muat();
  }

  void _info(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _bukaNotifikasi() async {
    await context.push<void>('/notifikasi');
    if (mounted) unawaited(_notifikasiProvider.muat());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.home),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WarnaJosBook.navy,
              WarnaJosBook.biru,
              HomeWarna.gradasiTerang,
              Colors.white,
            ],
            stops: [0.0, 0.16, 0.32, 0.5],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: AnimatedBuilder(
                animation: _notifikasiProvider,
                builder: (context, _) => _isi(),
              ),
            ),
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: IgnorePointer(child: ToastLogin(tampil: _toastTampil)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _isi() {
    final HomeData? data = _data;

    if (data == null) {
      if (_memuat) {
        return const SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SkeletonHome(),
        );
      }
      return ErrorHome(
        pesan: _pesanError ?? 'Terjadi kesalahan.',
        onUlang: _ulang,
      );
    }

    final bool wajibGanti = context.watch<AuthProvider>().wajibGantiPassword;

    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          HeaderHome(
            sekolah: data.sekolah,
            jumlahBelumDibaca: _notifikasiProvider.jumlahBelumDibaca,
            onNotifikasi: _bukaNotifikasi,
          ),
          const SizedBox(height: 24),
          SapaanHome(data: data),
          const SizedBox(height: 28),
          if (wajibGanti) ...[
            _bannerGantiPassword(),
            const SizedBox(height: 16),
          ],
          RingkasanHome(
            data: data,
            onSemester: () => context.go('/nilai'),
            onBukuInduk: () => context.go('/biodata'),
            onNilai: () => context.go('/nilai'),
            onUnduh: () => context.go('/unduh'),
          ),
          const SizedBox(height: 24),
          AktivitasHome(
            items: _notifikasiProvider.items
                .take(3)
                .map(_aktivitasDariNotifikasi)
                .toList(growable: false),
            onItem: _bukaNotifikasi,
            onLihatSemua: _bukaNotifikasi,
            memuat: _notifikasiProvider.memuat,
            pesanError: _notifikasiProvider.error,
            onUlang: () => unawaited(_notifikasiProvider.muat()),
          ),
        ],
      ),
    );
  }

  ItemAktivitas _aktivitasDariNotifikasi(Notifikasi item) => ItemAktivitas(
    judul: item.judul,
    waktu: formatWaktuWib(item.waktu),
    peringatan: item.jenis.toLowerCase() == 'peringatan',
  );

  Widget _bannerGantiPassword() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarna.oranye.withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: HomeWarna.oranye),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Akun ini wajib mengganti password. '
              '(Layar Ganti Password dibuat di tahap berikutnya.)',
              style: TextStyle(fontSize: 13, color: WarnaJosBook.teks),
            ),
          ),
        ],
      ),
    );
  }
}
