import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';
import 'otp_screen.dart';
import 'widgets/field_auth.dart';
import 'widgets/kotak_error_auth.dart';
import 'widgets/latar_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _passwordBaru = TextEditingController();
  final TextEditingController _konfirmasiPassword = TextEditingController();

  String? _errorLokal;
  bool _emailBermasalah = false;
  bool _passwordBermasalah = false;
  bool _konfirmasiBermasalah = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().hapusError();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _passwordBaru.dispose();
    _konfirmasiPassword.dispose();
    super.dispose();
  }

  String? _validasi() {
    final String email = _email.text.trim();
    final String passwordBaru = _passwordBaru.text;
    final String konfirmasi = _konfirmasiPassword.text;

    _emailBermasalah = email.isEmpty;
    _passwordBermasalah = passwordBaru.isEmpty;
    _konfirmasiBermasalah = konfirmasi.isEmpty;

    if (email.isEmpty || passwordBaru.isEmpty || konfirmasi.isEmpty) {
      return 'Semua kolom wajib diisi.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _emailBermasalah = true;
      return 'Format email tidak valid.';
    }

    if (passwordBaru.length < 8) {
      _passwordBermasalah = true;
      return 'Password minimal 8 karakter.';
    }

    if (passwordBaru != konfirmasi) {
      _konfirmasiBermasalah = true;
      return 'Konfirmasi password tidak sesuai.';
    }

    return null;
  }

  Future<void> _simpanPerubahan() async {
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final String? pesan = _validasi();

    if (pesan != null) {
      setState(() => _errorLokal = pesan);
      return;
    }

    setState(() => _errorLokal = null);
    final bool berhasil = await auth.lupaPassword(
      email: _email.text.trim(),
      passwordBaru: _passwordBaru.text,
    );

    if (!mounted) return;

    if (berhasil) {
      final String email = _email.text.trim();
      context.go(
        '/verifikasi-otp',
        extra: OtpRouteData(
          email: email,
          emailTersamar: _samarkanEmail(email),
          tujuan: 'lupa_password',
          jedaKirimUlangDetik: auth.otpSisaDetik ?? 60,
        ),
      );
      return;
    }

    final String pesanError =
        auth.pesanError ??
        'Email atau kata sandi yang dimasukkan tidak sesuai.';
    setState(() => _errorLokal = pesanError);
  }

  String _samarkanEmail(String email) {
    final int pemisah = email.indexOf('@');
    if (pemisah <= 0) return email;
    final String nama = email.substring(0, pemisah);
    final String namaDisamarkan = nama.length <= 2
        ? nama
        : '${nama.substring(0, 2)}****';
    return '$namaDisamarkan${email.substring(pemisah)}';
  }

  void _bersihkanError() {
    if (_errorLokal != null ||
        _emailBermasalah ||
        _passwordBermasalah ||
        _konfirmasiBermasalah) {
      setState(() {
        _errorLokal = null;
        _emailBermasalah = false;
        _passwordBermasalah = false;
        _konfirmasiBermasalah = false;
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
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Lupa Kata Sandi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: WarnaJosBook.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                if (error != null)
                  KotakErrorAuth(judul: 'Lupa Kata Sandi gagal', pesan: error),
                FieldAuth(
                  key: const ValueKey('email_lupa_password'),
                  label: 'Konfirmasi Email',
                  hint: 'Masukkan email Anda',
                  controller: _email,
                  adaError: _emailBermasalah || auth.pesanError != null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _bersihkanError(),
                ),
                const SizedBox(height: 14),
                FieldAuth(
                  key: const ValueKey('password_lupa_password'),
                  label: 'Kata Sandi Baru',
                  hint: 'Minimal 8 karakter',
                  controller: _passwordBaru,
                  sandi: true,
                  adaError: _passwordBermasalah || auth.pesanError != null,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _bersihkanError(),
                ),
                const SizedBox(height: 14),
                FieldAuth(
                  key: const ValueKey('konfirmasi_password_lupa_password'),
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi baru',
                  controller: _konfirmasiPassword,
                  sandi: true,
                  adaError: _konfirmasiBermasalah || auth.pesanError != null,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => _bersihkanError(),
                  onSubmitted: (_) => _simpanPerubahan(),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: auth.sedangMemproses ? null : _simpanPerubahan,
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
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ingat Kata Sandi? ',
                      style: TextStyle(
                        color: WarnaJosBook.teks,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<AuthProvider>().batalkanLupaPassword();
                        context.go('/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: WarnaJosBook.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
