import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../shared/widgets/animasi_josbook.dart';
import '../../shared/widgets/latar_halaman.dart';
import '../../shared/widgets/navbar.dart';
import '../../shared/widgets/state_views.dart';
import '../unduh/unduh_service.dart';
import 'biodata_model.dart';
import 'biodata_service.dart';

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key, this.service, this.unduhService});

  final BiodataService? service;
  final UnduhService? unduhService;

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  late final BiodataService _service;
  late final UnduhService _unduhService;
  BiodataData? _data;
  String? _error;
  bool _memuat = true;
  bool _sedangUnduh = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BiodataService();
    _unduhService = widget.unduhService ?? UnduhService();
    unawaited(_muat());
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final BiodataData data = await _service.ambil();
      if (!mounted) return;
      setState(() {
        _data = data;
        _memuat = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ApiException
            ? error.pesan
            : 'Terjadi kesalahan saat memuat biodata. Coba lagi.';
        _memuat = false;
      });
    }
  }

  Future<void> _unduh() async {
    if (_sedangUnduh) return;
    setState(() => _sedangUnduh = true);
    try {
      await _unduhService.unduh(jenis: JenisUnduhan.biodata);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unduhan gagal: ${error is ApiException ? error.pesan : 'Coba lagi.'}',
            ),
            backgroundColor: WarnaJosBook.merah,
          ),
        );
    } finally {
      if (mounted) setState(() => _sedangUnduh = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarHalamanJosBook,
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.biodata),
      body: LatarGradasiJosBook(
        child: SafeArea(
          child: Column(
            children: [
              HeaderHalamanJosBook(
                judul: 'Biodata',
                tooltipKembali: 'Kembali ke Home',
                onKembali: () => context.go('/home'),
              ),
              Expanded(child: _konten()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _konten() {
    if (_memuat) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorStateView(
            title: 'Biodata gagal dimuat.',
            message: _error!,
            onRetry: () => unawaited(_muat()),
            titleStyle: const TextStyle(color: WarnaJosBook.teks),
            messageStyle: const TextStyle(color: WarnaJosBook.teks),
          ),
        ),
      );
    }

    final data = _data!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        MasukBertahap(
          tunda: Duration.zero,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: WarnaJosBook.navy.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: WarnaJosBook.navy,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'HANYA LIHAT',
                    style: TextStyle(
                      color: WarnaJosBook.navy,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        MasukBertahap(
          tunda: const Duration(milliseconds: 70),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: garisKartuJosBook),
              boxShadow: [
                BoxShadow(
                  color: WarnaJosBook.navy.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < data.baris.length; i++)
                  _BarisBiodata(
                    label: data.baris[i].key,
                    nilai: data.baris[i].value,
                    terakhir: i == data.baris.length - 1,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        MasukBertahap(
          tunda: const Duration(milliseconds: 140),
          child: KartuTekan(
            child: SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _sedangUnduh ? null : _unduh,
                style: FilledButton.styleFrom(
                  backgroundColor: WarnaJosBook.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _sedangUnduh
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.file_download_outlined),
                label: Text(
                  _sedangUnduh ? 'Menyiapkan PDF...' : 'Unduh biodata (PDF)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarisBiodata extends StatelessWidget {
  const _BarisBiodata({
    required this.label,
    required this.nilai,
    this.terakhir = false,
  });

  final String label;
  final String nilai;
  final bool terakhir;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: terakhir
            ? null
            : const Border(bottom: BorderSide(color: garisKartuJosBook)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: teksPudarJosBook, fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WarnaJosBook.teks,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
