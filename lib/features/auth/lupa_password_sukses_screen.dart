import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../home/widgets/latar_auth.dart';

class LupaPasswordSuksesScreen extends StatelessWidget {
  const LupaPasswordSuksesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LatarAuth(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFE8F6ED),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 42,
                  color: Color(0xFF218838),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kata Sandi Berhasil Diperbarui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WarnaJosBook.navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Password Anda telah berhasil diubah. Silakan login kembali.',
                textAlign: TextAlign.center,
                style: TextStyle(color: WarnaJosBook.teks),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => context.go('/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: WarnaJosBook.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ke Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
