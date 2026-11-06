import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../shared/widgets/latar_profil.dart';
import '../auth/auth_provider.dart';
import 'profil_provider.dart';

/// Ganti Password: password lama, baru (min. 8), dan konfirmasi.
/// Aturan sama dengan API (PUT /ganti-password) dan prototype.
class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _kunci = GlobalKey<FormState>();
  final _lama = TextEditingController();
  final _baru = TextEditingController();
  final _konfirmasi = TextEditingController();

  bool _lihatLama = false;
  bool _lihatBaru = false;
  bool _lihatKonfirmasi = false;
  bool _menyimpan = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfilProvider>().muat();
    });
  }

  @override
  void dispose() {
    _lama.dispose();
    _baru.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!(_kunci.currentState?.validate() ?? false)) return;

    setState(() {
      _menyimpan = true;
      _error = null;
    });

    final profil = context.read<ProfilProvider>();
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await profil.gantiPassword(
        lama: _lama.text,
        baru: _baru.text,
        konfirmasi: _konfirmasi.text,
      );
      auth.tandaiPasswordSudahDiganti();
      messenger.showSnackBar(
        const SnackBar(content: Text('Password berhasil diganti.')),
      );
      router.go('/profil');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.pesan);
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LatarProfil(
      judul: 'Ganti Password',
      kembaliKe: '/profil',
      isi: [
        KartuProfil(
          child: Form(
            key: _kunci,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IsianPassword(
                  label: 'Password Lama',
                  hint: 'Masukkan password lama',
                  controller: _lama,
                  terlihat: _lihatLama,
                  ubah: () => setState(() => _lihatLama = !_lihatLama),
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Isi password lama.' : null,
                ),
                _IsianPassword(
                  label: 'Password Baru',
                  hint: 'Masukkan password baru',
                  controller: _baru,
                  terlihat: _lihatBaru,
                  ubah: () => setState(() => _lihatBaru = !_lihatBaru),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.isEmpty) return 'Isi password baru.';
                    if (s.length < 8) return 'Password baru minimal 8 karakter.';
                    if (s == _lama.text) {
                      return 'Password baru harus berbeda dari password lama.';
                    }
                    return null;
                  },
                ),
                _IsianPassword(
                  label: 'Konfirmasi Password',
                  hint: 'Konfirmasi password baru',
                  controller: _konfirmasi,
                  terlihat: _lihatKonfirmasi,
                  ubah: () =>
                      setState(() => _lihatKonfirmasi = !_lihatKonfirmasi),
                  validator: (v) =>
                      v != _baru.text ? 'Konfirmasi password tidak sama.' : null,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFD64545),
                        fontSize: 12,
                      ),
                    ),
                  ),
                TombolBiru(
                  teks: 'Simpan Password',
                  memproses: _menyimpan,
                  onPressed: _simpan,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IsianPassword extends StatelessWidget {
  const _IsianPassword({
    required this.label,
    required this.hint,
    required this.controller,
    required this.terlihat,
    required this.ubah,
    required this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool terlihat;
  final VoidCallback ubah;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return IsianProfil(
      label: label,
      hint: hint,
      controller: controller,
      gelap: !terlihat,
      validator: validator,
      suffix: IconButton(
        onPressed: ubah,
        icon: Icon(
          terlihat ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: const Color(0xFF6B7A99),
        ),
      ),
    );
  }
}
