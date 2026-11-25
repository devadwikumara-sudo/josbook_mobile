import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../features/profil/profil_provider.dart';
import '../../../core/theme.dart';
import 'animasi_josbook.dart';
import 'latar_halaman.dart';

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
      backgroundColor: latarHalamanJosBook,
      bottomNavigationBar: navbar,
      body: LatarGradasiJosBook(
        stops: const [0.0, 0.24, 0.44, 0.62],
        child: SafeArea(
          child: Column(
            children: [
              HeaderHalamanJosBook(
                judul: judul,
                onKembali: () => context.go(kembaliKe),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    if (denganHeaderPengguna) ...[
                      MasukBertahap(
                        tunda: Duration.zero,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Center(
                              child: _Avatar(
                                foto: profil.foto,
                                sedangMengubahFoto: profil.sedangMengubahFoto,
                                onTap: () => _pilihFoto(context),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              profil.data?.nama ??
                                  (profil.memuat ? 'Memuat…' : '-'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                shadows: [
                                  Shadow(
                                    color: Color(0x40062A6B),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if ((profil.data?.subJudul ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaJosBook.navy.withValues(
                                    alpha: 0.24,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.32),
                                  ),
                                ),
                                child: Text(
                                  profil.data!.subJudul,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ] else
                      const SizedBox(height: 8),
                    MasukBertahap(
                      tunda: const Duration(milliseconds: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: isi,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pilihFoto(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final bool berhasil = await context.read<ProfilProvider>().pilihFoto();
      if (!context.mounted || !berhasil) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
        );
    } on ApiException catch (error) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.pesan)));
    } on PlatformException {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Galeri foto tidak dapat dibuka.')),
        );
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    this.foto,
    required this.sedangMengubahFoto,
    required this.onTap,
  });

  final Uint8List? foto;
  final bool sedangMengubahFoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ubah foto profil',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: sedangMengubahFoto ? null : onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2F6FED),
              ),
              child: ClipOval(
                child: foto != null
                    ? Image.memory(
                        foto!,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      )
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
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: sedangMengubahFoto
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: WarnaJosBook.navy,
                      ),
              ),
            ),
          ],
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
        border: Border.all(color: garisKartuJosBook),
        boxShadow: [
          BoxShadow(
            color: WarnaJosBook.navy.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A94A6),
              ),
              isDense: true,
              filled: !aktif,
              fillColor: const Color(0xFFEFEFEF),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
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
    return KartuTekan(
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: memproses ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: warna,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
                    fontSize: 13.5,
                  ),
                ),
        ),
      ),
    );
  }
}
