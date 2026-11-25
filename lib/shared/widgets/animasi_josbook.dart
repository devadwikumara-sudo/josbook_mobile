import 'dart:async';

import 'package:flutter/material.dart';

/// Animasi masuk bertahap (fade + slide halus dari bawah).
class MasukBertahap extends StatefulWidget {
  const MasukBertahap({
    super.key,
    required this.child,
    this.tunda = Duration.zero,
    this.durasi = const Duration(milliseconds: 420),
    this.jarakY = 18,
  });

  final Widget child;
  final Duration tunda;
  final Duration durasi;
  final double jarakY;

  @override
  State<MasukBertahap> createState() => _MasukBertahapState();
}

class _MasukBertahapState extends State<MasukBertahap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opasitas;
  late final Animation<Offset> _geser;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.durasi);
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _opasitas = Tween<double>(begin: 0, end: 1).animate(curved);
    _geser = Tween<Offset>(
      begin: Offset(0, widget.jarakY / 100),
      end: Offset.zero,
    ).animate(curved);

    if (widget.tunda == Duration.zero) {
      _ctrl.forward();
    } else {
      _timer = Timer(widget.tunda, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opasitas,
      child: SlideTransition(
        position: _geser,
        child: widget.child,
      ),
    );
  }
}

/// Pembungkus kartu/tombol dengan efek tekan membal (scale-down halus).
class KartuTekan extends StatefulWidget {
  const KartuTekan({
    super.key,
    required this.child,
    this.skalaTekan = 0.97,
  });

  final Widget child;
  final double skalaTekan;

  @override
  State<KartuTekan> createState() => _KartuTekanState();
}

class _KartuTekanState extends State<KartuTekan> {
  bool _ditekan = false;

  void _setTekan(bool nilai) {
    if (_ditekan != nilai && mounted) {
      setState(() => _ditekan = nilai);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setTekan(true),
      onPointerUp: (_) => _setTekan(false),
      onPointerCancel: (_) => _setTekan(false),
      child: AnimatedScale(
        scale: _ditekan ? widget.skalaTekan : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
