import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';
import 'widgets/kirim_ulang_otp.dart';
import 'widgets/kotak_error_auth.dart';
import 'widgets/kotak_otp.dart';
import 'widgets/latar_auth.dart';

class OtpRouteData {
  const OtpRouteData({
    required this.email,
    required this.emailTersamar,
    required this.tujuan,
    required this.jedaKirimUlangDetik,
  });

  final String email;
  final String emailTersamar;
  final String tujuan;
  final int jedaKirimUlangDetik;
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.data});

  final OtpRouteData? data;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _kode = '';
  String? _errorLokal;
  late int _jedaKirimUlangDetik;
  int _versiPenghitungWaktu = 0;

  @override
  void initState() {
    super.initState();
    _jedaKirimUlangDetik = widget.data?.jedaKirimUlangDetik ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().hapusError();
    });
  }

  Future<void> _verifikasi() async {
    final OtpRouteData? data = widget.data;
    if (data == null) return;

    FocusScope.of(context).unfocus();
    if (_kode.length != 6) {
      setState(() => _errorLokal = 'Masukkan 6 digit kode verifikasi.');
      return;
    }

    setState(() => _errorLokal = null);
    final bool berhasil = await context.read<AuthProvider>().verifikasiOtp(
      email: data.email,
      tujuan: data.tujuan,
      kode: _kode,
    );

    if (mounted && berhasil) context.go('/daftar-berhasil');
  }

  Future<void> _kirimUlang() async {
    final OtpRouteData? data = widget.data;
    if (data == null) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool berhasil = await auth.kirimUlangOtp(
      email: data.email,
      tujuan: data.tujuan,
    );
    if (!mounted) return;

    final int? jedaServer = auth.otpSisaDetik;
    if (jedaServer != null && jedaServer > 0) {
      setState(() {
        _jedaKirimUlangDetik = jedaServer;
        _versiPenghitungWaktu++;
      });
    } else if (berhasil) {
      setState(() {
        _jedaKirimUlangDetik = 60;
        _versiPenghitungWaktu++;
      });
    }
  }

  String? _pesanError(AuthProvider auth) {
    if (_errorLokal != null) return _errorLokal;
    final String? pesan = auth.pesanError;
    if (pesan == null) return null;

    final int? sisa = auth.otpSisaPercobaan;
    return sisa == null ? pesan : '$pesan Sisa percobaan: $sisa.';
  }

  String _judulError(AuthProvider auth) {
    switch (auth.kodeError) {
      case 'otp_salah':
        return 'Kode salah atau kedaluwarsa';
      case 'otp_terlalu_banyak':
        return 'Percobaan terlalu banyak';
      case 'tunggu':
        return 'Belum dapat mengirim ulang';
      default:
        return 'Verifikasi gagal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final OtpRouteData? data = widget.data;
    if (data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Data verifikasi tidak tersedia. Silakan daftar kembali.',
              ),
              TextButton(
                onPressed: () => context.go('/daftar'),
                child: const Text('Kembali ke Daftar'),
              ),
            ],
          ),
        ),
      );
    }

    final AuthProvider auth = context.watch<AuthProvider>();
    final String? error = _pesanError(auth);

    return Scaffold(
      body: LatarAuth(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 36,
                  color: WarnaJosBook.navy,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Verifikasi Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WarnaJosBook.navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kami telah mengirim kode verifikasi ke',
                textAlign: TextAlign.center,
                style: TextStyle(color: WarnaJosBook.teks),
              ),
              const SizedBox(height: 4),
              Text(
                data.emailTersamar,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: WarnaJosBook.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              if (error != null)
                KotakErrorAuth(judul: _judulError(auth), pesan: error),
              KotakOtp(
                onChanged: (kode) {
                  setState(() {
                    _kode = kode;
                    _errorLokal = null;
                  });
                  context.read<AuthProvider>().hapusError();
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: auth.sedangMemproses ? null : _verifikasi,
                  style: FilledButton.styleFrom(
                    backgroundColor: WarnaJosBook.navy,
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
                          'Verifikasi',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: auth.sedangMemproses
                    ? null
                    : () => context.go('/daftar'),
                child: const Text('Kembali'),
              ),
              const SizedBox(height: 8),
              KirimUlangOtp(
                key: ValueKey(_versiPenghitungWaktu),
                detikAwal: _jedaKirimUlangDetik,
                sedangMemproses: auth.sedangMemproses,
                onKirimUlang: _kirimUlang,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
