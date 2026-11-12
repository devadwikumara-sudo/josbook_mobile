import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/features/notifikasi/notifikasi_model.dart';
import 'package:josbook_mobile/features/notifikasi/notifikasi_screen.dart';
import 'package:josbook_mobile/features/notifikasi/notifikasi_service.dart';

void main() {
  testWidgets('loads notification cards and marks unread items as read', (
    tester,
  ) async {
    final service = _FakeNotifikasiService(
      const DaftarNotifikasi(
        items: [
          Notifikasi(
            id: '1',
            judul: 'Nilai diperbarui',
            deskripsi: 'Nilai Matematika telah diperbarui.',
            waktu: '2026-11-13T01:00:00Z',
            jenis: 'nilai',
            dibaca: false,
          ),
        ],
        jumlahBelumDibaca: 1,
      ),
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Nilai diperbarui'), findsOneWidget);
    expect(find.text('Nilai Matematika telah diperbarui.'), findsOneWidget);
    expect(service.idDitandai, ['1']);
    expect(find.bySemanticsLabel('Belum dibaca'), findsNothing);
  });

  testWidgets('offers retry after loading error and displays empty state', (
    tester,
  ) async {
    final service = _FakeNotifikasiService(
      const DaftarNotifikasi(items: [], jumlahBelumDibaca: 0),
      gagalMuatPertama: true,
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada notifikasi'), findsOneWidget);
    expect(service.jumlahPanggilan, 2);
  });

  testWidgets('shows loading state until the API responds', (tester) async {
    final pending = Completer<DaftarNotifikasi>();
    final service = _FakeNotifikasiService(
      const DaftarNotifikasi(items: [], jumlahBelumDibaca: 0),
      pending: pending,
    );

    await tester.pumpWidget(_app(service));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete(const DaftarNotifikasi(items: [], jumlahBelumDibaca: 0));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada notifikasi'), findsOneWidget);
  });

  testWidgets('tapping an unread card retries marking it as read', (
    tester,
  ) async {
    final service = _FakeNotifikasiService(
      const DaftarNotifikasi(
        items: [
          Notifikasi(
            id: '2',
            judul: 'Profil diperbarui',
            deskripsi: 'Data profil berhasil diperbarui.',
            waktu: '2026-11-13T01:00:00Z',
            jenis: 'info',
            dibaca: false,
          ),
        ],
        jumlahBelumDibaca: 1,
      ),
      gagalTandaiPertama: true,
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    expect(_finderTitikBelumDibaca(), findsOneWidget);

    await tester.tap(find.text('Profil diperbarui'));
    await tester.pumpAndSettle();

    expect(service.jumlahPercobaanTandai, 2);
    expect(service.idDitandai, ['2']);
    expect(_finderTitikBelumDibaca(), findsNothing);
  });
}

Widget _app(NotifikasiService service) =>
    MaterialApp(home: NotifikasiScreen(service: service));

Finder _finderTitikBelumDibaca() => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == 'Belum dibaca',
);

class _FakeNotifikasiService implements NotifikasiService {
  _FakeNotifikasiService(
    this.daftar, {
    this.gagalMuatPertama = false,
    this.pending,
    this.gagalTandaiPertama = false,
  });

  final DaftarNotifikasi daftar;
  final bool gagalMuatPertama;
  final Completer<DaftarNotifikasi>? pending;
  final bool gagalTandaiPertama;
  final List<String> idDitandai = [];
  int jumlahPanggilan = 0;
  int jumlahPercobaanTandai = 0;

  @override
  Future<DaftarNotifikasi> ambilNotifikasi() async {
    jumlahPanggilan++;
    if (gagalMuatPertama && jumlahPanggilan == 1) {
      throw Exception('server sementara tidak tersedia');
    }
    if (pending != null) return pending!.future;
    return daftar;
  }

  @override
  Future<void> tandaiDibaca(String id) async {
    jumlahPercobaanTandai++;
    if (gagalTandaiPertama && jumlahPercobaanTandai == 1) {
      throw Exception('server sementara tidak tersedia');
    }
    idDitandai.add(id);
  }
}
