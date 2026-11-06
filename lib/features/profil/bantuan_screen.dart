import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../shared/widgets/latar_profil.dart';

/// Bantuan: FAQ (isi sama dengan prototype) + tombol Chat Admin.
class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const List<(String, String)> _faq = [
    (
      'Cara melakukan absensi',
      'Absensi dicatat oleh wali kelas dan dapat dilihat di menu Nilai dan Biodata.',
    ),
    (
      'Cara melihat riwayat absensi',
      'Buka menu Unduh lalu pilih Hadir untuk melihat riwayat per semester.',
    ),
    (
      'Cara mengubah profil',
      'Buka Profil, pilih Edit Profil, ubah email, nomor HP, atau alamat, lalu simpan.',
    ),
    (
      'Cara mengganti password',
      'Buka Profil, pilih Ganti Password, isi password lama dan baru.',
    ),
  ];

  Future<void> _chatAdmin(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (KontakAdmin.whatsapp.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Kontak admin belum diatur. Hubungi admin sekolah langsung.'),
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/${KontakAdmin.whatsapp}'
      '?text=${Uri.encodeComponent('Halo Admin JosBook, saya butuh bantuan.')}',
    );

    bool berhasil = false;
    try {
      berhasil = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      berhasil = false;
    }
    if (!berhasil) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LatarProfil(
      judul: 'Bantuan',
      kembaliKe: '/profil',
      denganHeaderPengguna: false,
      isi: [
        KartuProfil(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_outline_rounded,
                      size: 20, color: Color(0xFF8A94A6)),
                  SizedBox(width: 8),
                  Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF123A82),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final f in _faq) _ItemFaq(tanya: f.$1, jawab: f.$2),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KartuProfil(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.headset_mic_outlined,
                      size: 18, color: Color(0xFF8A94A6)),
                  SizedBox(width: 8),
                  Text(
                    'Hubungi Admin',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF123A82),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika mengalami kendala, silakan hubungi admin kami.',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7A99)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _chatAdmin(context),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text(
                    'Chat Admin',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F6FEB),
                    side: const BorderSide(color: Color(0xFF1F6FEB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemFaq extends StatelessWidget {
  const _ItemFaq({required this.tanya, required this.jawab});

  final String tanya;
  final String jawab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6E0F0)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            expandedAlignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              tanya,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: WarnaJosBook.teks,
              ),
            ),
            children: [
              Text(
                jawab,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF51607F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
