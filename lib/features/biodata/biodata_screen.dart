import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
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
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.biodata),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WarnaJosBook.navy,
              Color(0xFF2F80ED),
              Color(0xFFEAF2FF),
              Colors.white,
            ],
            stops: [0, 0.22, 0.42, 0.58],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 72,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Kembali ke Home',
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Biodata',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
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
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'HANYA LIHAT',
            style: TextStyle(
              color: WarnaJosBook.navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (final row in data.baris)
                _BarisBiodata(label: row.key, nilai: row.value),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 46,
          child: FilledButton.icon(
            onPressed: _sedangUnduh ? null : _unduh,
            style: FilledButton.styleFrom(
              backgroundColor: WarnaJosBook.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
            ),
          ),
        ),
      ],
    );
  }
}

class _BarisBiodata extends StatelessWidget {
  const _BarisBiodata({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4EAF2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WarnaJosBook.teks,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
