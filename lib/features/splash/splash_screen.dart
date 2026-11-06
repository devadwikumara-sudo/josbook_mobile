import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  /// Dipanggil setelah animasi splash selesai. Router yang menentukan
  /// tujuan berikutnya (Login atau Home) berdasarkan status auth.
  final VoidCallback onSelesai;

  const SplashScreen({super.key, required this.onSelesai});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _gelombangGeser;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Gelombang naik dari bawah (0% - 60% durasi)
    _gelombangGeser = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Logo fade in (25% - 70% durasi)
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );

    // Logo membesar dengan efek membal halus (25% - 85% durasi)
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _jalankan();
  }

  Future<void> _jalankan() async {
    await _controller.forward();
    if (!mounted) return;

    // Tahan sebentar supaya logo sempat terbaca
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    widget.onSelesai();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size layar = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo (sudah termasuk teks JOSBOOK dan tagline)
          Align(
            alignment: const Alignment(0, -0.2),
            child: FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
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
            ),
          ),

          // Gelombang di bagian bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _gelombangGeser,
              child: SizedBox(
                height: layar.height * 0.32,
                child: CustomPaint(
                  painter: WavePainter(),
                ),
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