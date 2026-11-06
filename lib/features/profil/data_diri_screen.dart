import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../shared/widgets/latar_profil.dart';
import 'profil_provider.dart';

/// Data Diri: baris informasi hanya-baca.
class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfilProvider>().muat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ProfilProvider>().data;

    String isi(String? s, [String kosong = '-']) =>
        (s == null || s.trim().isEmpty) ? kosong : s.trim();

    final baris = <_Baris>[
      _Baris(Icons.person_outline_rounded, 'Nama Lengkap', isi(d?.nama)),
      _Baris(Icons.school_outlined, 'Kelas', isi(d?.kelas)),
      _Baris(Icons.wc_rounded, 'Jenis Kelamin',
          isi(d?.jenisKelamin, 'Tidak Diketahui')),
      _Baris(Icons.cake_outlined, 'Tempat / Tanggal Lahir',
          d?.tempatTanggalLahir ?? '-'),
      _Baris(Icons.home_outlined, 'Alamat', isi(d?.alamat)),
      _Baris(Icons.mail_outline_rounded, 'Email', isi(d?.email)),
      _Baris(Icons.phone_outlined, 'Nomor HP', isi(d?.nomorHp)),
    ];

    return LatarProfil(
      judul: 'Data Diri',
      kembaliKe: '/profil',
      isi: [
        KartuProfil(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (var i = 0; i < baris.length; i++) ...[
                baris[i],
                if (i != baris.length - 1)
                  const Divider(height: 1, color: Color(0xFFEAEFF7)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.ikon, this.label, this.nilai);

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WarnaJosBook.biruMuda,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, size: 20, color: const Color(0xFF2F6FED)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A94A6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nilai,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: WarnaJosBook.teks,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
