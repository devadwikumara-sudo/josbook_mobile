import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';

/// Layar Login (desain: login 1 - login 4).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _sembunyikan = true;
  String? _errorLokal;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();

    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _errorLokal = 'Username dan password wajib diisi.');
      return;
    }

    setState(() => _errorLokal = null);
    await context.read<AuthProvider>().login(_username.text, _password.text);
    // Jika berhasil, router otomatis pindah ke Home.
  }

  void _segeraHadir(String nama) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nama akan dibuat pada tahap berikutnya.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final error = _errorLokal ?? auth.pesanError;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFF3B8EEA), WarnaJosBook.navy],
            stops: [0.25, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/josbook-logo.png',
                    height: 170,
                    errorBuilder: (_, __, ___) => const SizedBox(
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
                  ),
                  const SizedBox(height: 24),
                  _tab(),
                  const SizedBox(height: 20),
                  if (error != null) _bannerError(error),
                  _label('Email / NISN / Username'),
                  TextField(
                    controller: _username,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    onChanged: (_) => auth.hapusError(),
                    decoration: _hiasan('Masukkan username'),
                  ),
                  const SizedBox(height: 14),
                  _label('Password'),
                  TextField(
                    controller: _password,
                    obscureText: _sembunyikan,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _masuk(),
                    onChanged: (_) => auth.hapusError(),
                    decoration: _hiasan('Masukkan password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_sembunyikan
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _sembunyikan = !_sembunyikan),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _segeraHadir('Lupa password'),
                      child: const Text(
                        'Lupa password?',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: auth.sedangMemproses ? null : _masuk,
                      style: FilledButton.styleFrom(
                        backgroundColor: WarnaJosBook.navy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.sedangMemproses
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Login',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab() {
    Widget item(String teks, bool aktif, VoidCallback aksi) => Expanded(
          child: GestureDetector(
            onTap: aksi,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: aktif ? WarnaJosBook.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                teks,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: aktif ? Colors.white : WarnaJosBook.teks,
                ),
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        item('Masuk', true, () {}),
        item('Daftar', false, () => _segeraHadir('Halaman Daftar')),
      ]),
    );
  }

  Widget _bannerError(String pesan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WarnaJosBook.merah.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: WarnaJosBook.merah),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Login gagal',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: WarnaJosBook.merah)),
                const SizedBox(height: 2),
                Text(pesan,
                    style: const TextStyle(
                        fontSize: 13, color: WarnaJosBook.teks)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(teks,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: WarnaJosBook.teks)),
      );

  InputDecoration _hiasan(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}