import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';

/// Lima tab utama aplikasi.
enum TabNav { home, biodata, nilai, unduh, profil }

/// Navbar bawah JosBook (Home, Biodata, Nilai, Unduh, Profil).
///
/// Cara pakai di layar mana pun:
///
///   Scaffold(
///     body: ...,
///     bottomNavigationBar: const NavbarJosBook(aktif: TabNav.biodata),
///   )
///
/// Mengetuk tab akan berpindah halaman lewat go_router (rute ada di app.dart).
class NavbarJosBook extends StatelessWidget {
  const NavbarJosBook({super.key, required this.aktif});

  /// Tab yang sedang ditampilkan (disorot biru + garis bawah).
  final TabNav aktif;

  static const Color _warnaAktif = Color(0xFF3D9BFF);

  static const List<_ItemNav> _daftar = [
    _ItemNav(TabNav.home, 'Home', '/home',
        Icons.home_outlined, Icons.home_rounded),
    _ItemNav(TabNav.biodata, 'Biodata', '/biodata',
        Icons.assignment_outlined, Icons.assignment_rounded),
    _ItemNav(TabNav.nilai, 'Nilai', '/nilai',
        Icons.menu_book_outlined, Icons.menu_book_rounded),
    _ItemNav(TabNav.unduh, 'Unduh', '/unduh',
        Icons.swap_horiz_rounded, Icons.swap_horiz_rounded),
    _ItemNav(TabNav.profil, 'Profil', '/profil',
        Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WarnaJosBook.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Row(
            children: [
              for (final item in _daftar)
                Expanded(
                  child: _TombolNav(
                    item: item,
                    aktif: item.tab == aktif,
                    onTap: () {
                      if (item.tab != aktif) context.go(item.path);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNav {
  const _ItemNav(this.tab, this.label, this.path, this.ikon, this.ikonAktif);

  final TabNav tab;
  final String label;
  final String path;
  final IconData ikon;
  final IconData ikonAktif;
}

class _TombolNav extends StatelessWidget {
  const _TombolNav({
    required this.item,
    required this.aktif,
    required this.onTap,
  });

  final _ItemNav item;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warna = aktif ? NavbarJosBook._warnaAktif : Colors.white;

    return Semantics(
      button: true,
      selected: aktif,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(aktif ? item.ikonAktif : item.ikon, color: warna, size: 26),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  color: warna,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              // Garis bawah penanda tab aktif
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                width: aktif ? 26 : 0,
                decoration: BoxDecoration(
                  color: NavbarJosBook._warnaAktif,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}