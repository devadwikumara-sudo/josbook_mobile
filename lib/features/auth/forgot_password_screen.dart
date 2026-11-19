import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';
import '../home/widgets/field_auth.dart';
import '../home/widgets/kotak_error_auth.dart';
import '../home/widgets/latar_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();

  String? _errorLokal;
  bool _emailBermasalah = false;

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
    super.dispose();
  }

  String? _validasi() {
    final String email = _email.text.trim();

    _emailBermasalah = email.isEmpty;

    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _emailBermasalah = true;
      return 'Format email tidak valid.';
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
    final bool berhasil = await auth.lupaPassword(email: _email.text.trim());

    if (!mounted) return;

    if (berhasil) {
      context.go('/lupa-password-sukses');
      return;
    }

    final String pesanError = auth.pesanError ?? 'Permintaan reset gagal.';
    setState(() => _errorLokal = pesanError);
  }

  void _bersihkanError() {
    if (_errorLokal != null || _emailBermasalah || _emailBermasalah) {
      setState(() {
        _errorLokal = null;
        _emailBermasalah = false;
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
                            'Kirim Tautan Reset',
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
                      onTap: () => context.go('/login'),
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
