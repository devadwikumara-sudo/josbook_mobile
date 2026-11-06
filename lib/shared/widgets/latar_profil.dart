import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/profil/profil_provider.dart';
import '../../../core/theme.dart';

/// Kerangka semua layar Profil: latar gradasi biru, judul + tombol kembali,
/// avatar, nama, dan "Kelas | NISN" (sesuai desain Profil/Data Diri/Edit/Ganti Password).
class LatarProfil extends StatelessWidget {
  const LatarProfil({
    super.key,
    required this.judul,
    required this.kembaliKe,
    required this.isi,
    this.navbar,
    this.denganHeaderPengguna = true,
  });

  final String judul;

  /// Rute tujuan tombol panah kembali.
  final String kembaliKe;
  final List<Widget> isi;
  final Widget? navbar;

  /// false untuk layar Bantuan (desain tidak menampilkan avatar).
  final bool denganHeaderPengguna;

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilProvider>();

    return Scaffold(
      bottomNavigationBar: navbar,
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
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () => context.go(kembaliKe),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        judul,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    if (denganHeaderPengguna) ...[
                      const SizedBox(height: 12),
                      Center(child: _Avatar(foto: profil.foto)),
                      const SizedBox(height: 14),
                      Text(
                        profil.data?.nama ?? (profil.memuat ? 'Memuat…' : '-'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profil.data?.subJudul ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ] else
                      const SizedBox(height: 8),
                    ...isi,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.foto});

  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2F6FED),
      ),
      child: ClipOval(
        child: foto != null
            ? Image.memory(foto!, fit: BoxFit.cover, width: 90, height: 90)
            : Container(
                color: const Color(0xFFDCE9FF),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 56,
                  color: Color(0xFF1F3A8A),
                ),
              ),
      ),
    );
  }
}

/// Kartu putih membulat tempat isi form / daftar (bayangan lembut seperti desain).
class KartuProfil extends StatelessWidget {
  const KartuProfil({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F062A6B),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Label tebal + kolom isian bergaya desain (sudut 12, garis biru muda).
class IsianProfil extends StatelessWidget {
  const IsianProfil({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.aktif = true,
    this.baris = 1,
    this.keyboardType,
    this.gelap = false,
    this.validator,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool aktif;
  final int baris;
  final TextInputType? keyboardType;

  /// Dipakai kolom password (teks disembunyikan; tombol mata lewat [suffix]).
  final bool gelap;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: WarnaJosBook.teks,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: aktif,
            obscureText: gelap,
            minLines: baris,
            maxLines: gelap ? 1 : baris,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 13, color: WarnaJosBook.teks),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8A94A6)),
              isDense: true,
              filled: !aktif,
              fillColor: const Color(0xFFEFEFEF),
              suffixIcon: suffix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: _garis(const Color(0xFFD6E0F0)),
              enabledBorder: _garis(const Color(0xFFD6E0F0)),
              disabledBorder: _garis(const Color(0xFFE2E2E2)),
              focusedBorder: _garis(const Color(0xFF2F80ED)),
              errorBorder: _garis(WarnaJosBook.merah),
              focusedErrorBorder: _garis(WarnaJosBook.merah),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _garis(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
}

/// Tombol biru penuh ("Simpan Perubahan", "Simpan Password").
class TombolBiru extends StatelessWidget {
  const TombolBiru({
    super.key,
    required this.teks,
    required this.onPressed,
    this.memproses = false,
    this.warna = const Color(0xFF2068CC),
  });

  final String teks;
  final VoidCallback? onPressed;
  final bool memproses;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton(
        onPressed: memproses ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: warna,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: memproses
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                teks,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
