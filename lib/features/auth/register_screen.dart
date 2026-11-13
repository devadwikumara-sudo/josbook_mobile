import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';
import 'otp_screen.dart';
import '../home/widgets/field_auth.dart';
import '../home/widgets/kotak_error_auth.dart';
import '../home/widgets/latar_auth.dart';
import '../home/widgets/tab_auth.dart';

/// Layar Daftar.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _nisn = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _errorLokal;
  bool _namaBermasalah = false;
  bool _nisnBermasalah = false;
  bool _emailBermasalah = false;
  bool _passwordBermasalah = false;

  @override
  void initState() {
    super.initState();
    // Bersihkan sisa error dari layar Login.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().hapusError();
    });
  }

  @override
  void dispose() {
    _nama.dispose();
    _nisn.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Validasi sisi mobile. Mengembalikan pesan error, atau null bila valid.
  String? _validasi() {
    final String nama = _nama.text.trim();
    final String nisn = _nisn.text.trim();
    final String email = _email.text.trim();
    final String password = _password.text;

    _namaBermasalah = nama.isEmpty;
    _nisnBermasalah = nisn.isEmpty;
    _emailBermasalah = email.isEmpty;
    _passwordBermasalah = password.isEmpty;

    if (nama.isEmpty || nisn.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Semua kolom wajib diisi.';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(nisn)) {
      _nisnBermasalah = true;
      return 'NISN harus terdiri dari 10 digit angka.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _emailBermasalah = true;
      return 'Format email tidak valid.';
    }

    if (password.length < 8) {
      _passwordBermasalah = true;
      return 'Password minimal 8 karakter.';
    }

    return null;
  }

  Future<void> _daftar() async {
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final String? pesan = _validasi();

    if (pesan != null) {
      setState(() => _errorLokal = pesan);
      return;
    }

    setState(() => _errorLokal = null);

    final Map<String, dynamic>? data = await auth.daftar(
      nama: _nama.text.trim(),
      nisn: _nisn.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;

    if (data != null) {
      final Object? jeda = data['jeda_kirim_ulang_detik'];
      context.go(
        '/verifikasi-otp',
        extra: OtpRouteData(
          email: _email.text.trim(),
          emailTersamar:
              data['email']?.toString() ?? _samarkanEmail(_email.text.trim()),
          tujuan: 'daftar',
          jedaKirimUlangDetik: jeda is num ? jeda.toInt() : 60,
        ),
      );
    }
  }

  String _samarkanEmail(String email) {
    final int pemisah = email.indexOf('@');
    if (pemisah <= 0) return email;
    final String nama = email.substring(0, pemisah);
    return '${nama.length <= 2 ? nama : '${nama.substring(0, 2)}****'}'
        '${email.substring(pemisah)}';
  }

  void _bersihkanError() {
    if (_errorLokal != null ||
        _namaBermasalah ||
        _nisnBermasalah ||
        _emailBermasalah ||
        _passwordBermasalah) {
      setState(() {
        _errorLokal = null;
        _namaBermasalah = false;
        _nisnBermasalah = false;
        _emailBermasalah = false;
        _passwordBermasalah = false;
      });
    }
    context.read<AuthProvider>().hapusError();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final String? error = _errorLokal ?? auth.pesanError;

    return Scaffold(
      body: LatarAuth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _logo(),
            const SizedBox(height: 24),
            TabAuth(
              masukAktif: false,
              onMasuk: () => context.go('/login'),
              onDaftar: () {},
            ),
            const SizedBox(height: 20),
            if (error != null)
              KotakErrorAuth(judul: 'Daftar gagal', pesan: error),
            FieldAuth(
              label: 'Nama Lengkap',
              hint: 'Masukkan Nama Lengkap',
              controller: _nama,
              adaError: _namaBermasalah,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _bersihkanError(),
            ),
            const SizedBox(height: 14),
            FieldAuth(
              label: 'NISN',
              hint: 'Masukkan NISN',
              controller: _nisn,
              adaError: _nisnBermasalah,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _bersihkanError(),
            ),
            const SizedBox(height: 14),
            FieldAuth(
              label: 'Email',
              hint: 'Masukkan Email',
              controller: _email,
              adaError: _emailBermasalah,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _bersihkanError(),
            ),
            const SizedBox(height: 14),
            FieldAuth(
              label: 'Password',
              hint: 'Masukkan password',
              controller: _password,
              sandi: true,
              adaError: _passwordBermasalah,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _bersihkanError(),
              onSubmitted: (_) => _daftar(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: auth.sedangMemproses ? null : _daftar,
                style: FilledButton.styleFrom(
                  backgroundColor: WarnaJosBook.navy,
                  disabledBackgroundColor: WarnaJosBook.navy.withValues(
                    alpha: 0.8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: auth.sedangMemproses
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Daftar', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun? ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset(
      'assets/images/josbook-logo.png',
      height: 170,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        height: 170,
        child: Center(
          child: Text(
            'JOSBOOK',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: WarnaJosBook.navy,
            ),
          ),
        ),
      ),
    );
  }
}
