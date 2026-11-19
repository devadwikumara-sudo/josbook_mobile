import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class KirimUlangOtp extends StatefulWidget {
  const KirimUlangOtp({
    super.key,
    required this.detikAwal,
    required this.sedangMemproses,
    required this.onKirimUlang,
  });

  final int detikAwal;
  final bool sedangMemproses;
  final VoidCallback onKirimUlang;

  @override
  State<KirimUlangOtp> createState() => _KirimUlangOtpState();
}

class _KirimUlangOtpState extends State<KirimUlangOtp> {
  Timer? _timer;
  late int _sisaDetik;

  @override
  void initState() {
    super.initState();
    _mulai(widget.detikAwal);
  }

  @override
  void didUpdateWidget(covariant KirimUlangOtp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detikAwal != widget.detikAwal) {
      _mulai(widget.detikAwal);
    }
  }

  void _mulai(int detik) {
    _timer?.cancel();
    _sisaDetik = detik < 0 ? 0 : detik;
    if (_sisaDetik == 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _sisaDetik--;
        if (_sisaDetik == 0) timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sisaDetik > 0) {
      final String menit = (_sisaDetik ~/ 60).toString().padLeft(2, '0');
      final String detik = (_sisaDetik % 60).toString().padLeft(2, '0');
      return Text(
        'Kirim ulang dalam $menit:$detik',
        textAlign: TextAlign.center,
        style: const TextStyle(color: WarnaJosBook.teks),
      );
    }

    return TextButton(
      onPressed: widget.sedangMemproses ? null : widget.onKirimUlang,
      child: widget.sedangMemproses
          ? Semantics(
              label: 'Mengirim ulang kode',
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : const Text(
              'Kirim ulang',
              style: TextStyle(
                color: WarnaJosBook.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
