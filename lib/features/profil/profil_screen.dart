import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';
import '../../shared/widgets/state_views.dart';
import 'profil_provider.dart';
import '../../shared/widgets/latar_profil.dart';

/// Tab Profil: avatar + empat menu + tombol Keluar Sesi.
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfilProvider>().muat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilProvider>();

    return LatarProfil(
      judul: 'Profil',
      kembaliKe: '/home',
      navbar: const NavbarJosBook(aktif: TabNav.profil),
      isi: [
        if (profil.error != null && profil.data == null)
          _KotakGagalMuat(
            pesan: profil.error!,
            onUlang: () => profil.muat(paksa: true),
          ),
        const _MenuProfil(
          ikon: Icons.badge_outlined,
          judul: 'Data Diri',
          rute: '/profil/data-diri',
        ),
        const _MenuProfil(
          ikon: Icons.edit_outlined,
          judul: 'Edit Profil',
          rute: '/profil/edit',
        ),
        const _MenuProfil(
          ikon: Icons.person_outline_rounded,
          judul: 'Ganti Password',
          rute: '/profil/ganti-password',
        ),
        const _MenuProfil(
          ikon: Icons.chat_outlined,
          judul: 'Bantuan',
          rute: '/profil/bantuan',
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: FilledButton(
            onPressed: () => context.go('/logout-semua?dari=profil'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE41E4D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Keluar Sesi',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuProfil extends StatelessWidget {
  const _MenuProfil({
    required this.ikon,
    required this.judul,
    required this.rute,
  });

  final IconData ikon;
  final String judul;
  final String rute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x33062A6B),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.go(rute),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WarnaJosBook.biruMuda,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ikon, size: 22, color: const Color(0xFF2F6FED)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WarnaJosBook.teks,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8A94A6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KotakGagalMuat extends StatelessWidget {
  const _KotakGagalMuat({required this.pesan, required this.onUlang});

  final String pesan;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: KartuProfil(
        child: ErrorStateView(
          message: pesan,
          onRetry: onUlang,
          compact: true,
          messageStyle: const TextStyle(
            color: WarnaJosBook.merah,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
