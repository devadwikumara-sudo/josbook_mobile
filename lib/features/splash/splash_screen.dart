import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  /// Dipanggil setelah jeda splash selesai. Router yang menentukan
  /// tujuan berikutnya (Login atau Home).
  final VoidCallback onSelesai;

  const SplashScreen({super.key, required this.onSelesai});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _tungguLaluSelesai();
  }

  Future<void> _tungguLaluSelesai() async {
    // Jeda splash 2 detik
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    widget.onSelesai();
  }

  @override
  Widget build(BuildContext context) {
    final Size layar = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo (sudah termasuk teks JOSBOOK dan tagline)
          Align(
            alignment: const Alignment(0, -0.2),
            child: Image.asset(
              'assets/images/josbook-logo.png',
              width: layar.width * 0.65,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text(
                'JOSBOOK',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0055FF),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // Gelombang di bagian bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: layar.height * 0.32,
              child: CustomPaint(
                painter: WavePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Lapisan 1: biru tua (paling belakang, tipis di atas)
    final Paint paintBelakang = Paint()
      ..color = const Color(0xFF0A3FA8)
      ..style = PaintingStyle.fill;

    final Path pathBelakang = Path()
      ..moveTo(0, h * 0.10)
      ..cubicTo(w * 0.35, h * -0.02, w * 0.70, h * 0.45, w, h * 0.30)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pathBelakang, paintBelakang);

    // Lapisan 2: pita putih
    final Paint paintPutih = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path pathPutih = Path()
      ..moveTo(0, h * 0.22)
      ..cubicTo(w * 0.35, h * 0.08, w * 0.65, h * 0.58, w, h * 0.42)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pathPutih, paintPutih);

    // Lapisan 3: biru gradasi (paling depan)
    final Paint paintDepan = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E7BFF), Color(0xFF0A3FA8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final Path pathDepan = Path()
      ..moveTo(0, h * 0.34)
      ..cubicTo(w * 0.35, h * 0.20, w * 0.65, h * 0.70, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pathDepan, paintDepan);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}