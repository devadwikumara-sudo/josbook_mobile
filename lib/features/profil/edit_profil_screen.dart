import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../shared/widgets/latar_profil.dart';
import 'profil_provider.dart';

/// Edit Profil: nama & kelas terkunci (hanya admin), siswa boleh ubah
/// email, nomor HP, dan alamat.
class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _kunci = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _kelas = TextEditingController();
  final _email = TextEditingController();
  final _hp = TextEditingController();
  final _alamat = TextEditingController();

  bool _sudahIsi = false;
  bool _menyimpan = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ProfilProvider>().muat();
      if (mounted) _isiForm();
    });
  }

  void _isiForm() {
    final d = context.read<ProfilProvider>().data;
    if (d == null || _sudahIsi) return;
    _sudahIsi = true;
    _nama.text = d.nama;
    _kelas.text = d.kelas ?? '-';
    _email.text = d.email ?? '';
    _hp.text = d.nomorHp ?? '';
    _alamat.text = d.alamatJalan ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nama.dispose();
    _kelas.dispose();
    _email.dispose();
    _hp.dispose();
    _alamat.dispose();
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
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await profil.simpan(
        email: _email.text,
        nomorHp: _hp.text,
        alamat: _alamat.text,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
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
      judul: 'Edit Profil',
      kembaliKe: '/profil',
      isi: [
        KartuProfil(
          child: Form(
            key: _kunci,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IsianProfil(
                  label: 'Nama Lengkap',
                  controller: _nama,
                  aktif: false,
                ),
                IsianProfil(
                  label: 'Kelas',
                  controller: _kelas,
                  aktif: false,
                ),
                IsianProfil(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Email wajib diisi.';
                    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                    return ok ? null : 'Format email tidak valid.';
                  },
                ),
                IsianProfil(
                  label: 'Nomor HP',
                  controller: _hp,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return null;
                    return RegExp(r'^[0-9+\-\s]*$').hasMatch(s)
                        ? null
                        : 'Nomor HP hanya boleh berisi angka.';
                  },
                ),
                IsianProfil(
                  label: 'Alamat',
                  controller: _alamat,
                  baris: 3,
                  keyboardType: TextInputType.streetAddress,
                  validator: (v) => (v ?? '').length > 255
                      ? 'Alamat maksimal 255 karakter.'
                      : null,
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
                  teks: 'Simpan Perubahan',
                  memproses: _menyimpan,
                  onPressed: _sudahIsi ? _simpan : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
