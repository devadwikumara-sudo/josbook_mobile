import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';
import 'widgets/field_auth.dart';
import 'widgets/kotak_error_auth.dart';
import 'widgets/latar_auth.dart';
import 'widgets/tab_auth.dart';
import 'widgets/tombol_google_auth.dart';

/// Layar Login (desain: login 1 - login 4).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _errorLokal;
  bool _usernameBermasalah = false;
  bool _passwordBermasalah = false;

  @override
  void initState() {
    super.initState();
    // Bersihkan sisa error dari layar lain (misalnya layar Daftar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().hapusError();
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Validasi sisi mobile. Mengembalikan pesan error, atau null bila valid.
  /// (Aturan panjang password minimal 8 karakter ada di layar Daftar/Lupa
  /// sandi, bukan di sini, supaya password lama tetap bisa dipakai login.)
  String? _validasi() {
    final String username = _username.text.trim();
    final String password = _password.text;

    _usernameBermasalah = username.isEmpty;
    _passwordBermasalah = password.isEmpty;

    if (username.isEmpty || password.isEmpty) {
      return 'Username dan password wajib diisi.';
    }

    // Bila yang diketik hanya angka, anggap NISN: harus tepat 10 digit.
    final bool hanyaAngka = RegExp(r'^\d+$').hasMatch(username);
    if (hanyaAngka && username.length != 10) {
      _usernameBermasalah = true;
      return 'NISN harus terdiri dari 10 digit angka.';
    }

    return null;
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final String? pesan = _validasi();

    if (pesan != null) {
      setState(() => _errorLokal = pesan);
      return;
    }

    setState(() => _errorLokal = null);
    await auth.login(_username.text.trim(), _password.text);
    // Jika berhasil, router otomatis pindah ke Home.
  }

  void _bersihkanError() {
    if (_errorLokal != null || _usernameBermasalah || _passwordBermasalah) {
      setState(() {
        _errorLokal = null;
        _usernameBermasalah = false;
        _passwordBermasalah = false;
      });
    }
    context.read<AuthProvider>().hapusError();
  }

  void _tampilkanInfo(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
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
              masukAktif: true,
              onMasuk: () {},
              onDaftar: () => context.go('/daftar'),
            ),
            const SizedBox(height: 20),
            if (error != null)
              KotakErrorAuth(judul: 'Login gagal', pesan: error),
            FieldAuth(
              label: 'Email / NISN / Username',
              hint: 'Masukkan username',
              controller: _username,
              adaError: _usernameBermasalah,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _bersihkanError(),
            ),
            const SizedBox(height: 14),
            FieldAuth(
              label: 'Password',
              hint: 'Masukkan password',
              controller: _password,
              sandi: true,
              adaError: _passwordBermasalah || auth.pesanError != null,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _bersihkanError(),
              onSubmitted: (_) => _masuk(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _tampilkanInfo(
                    'Halaman Lupa password akan dibuat pada tahap berikutnya.'),
                child: const Text(
                  'Lupa password?',
                  style: TextStyle(
                    color: WarnaJosBook.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TombolGoogleAuth(
              onTap: () => _tampilkanInfo('Login dengan Google segera hadir.'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: auth.sedangMemproses ? null : _masuk,
                style: FilledButton.styleFrom(
                  backgroundColor: WarnaJosBook.navy,
                  disabledBackgroundColor:
                      WarnaJosBook.navy.withValues(alpha: 0.8),
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
                    : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
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